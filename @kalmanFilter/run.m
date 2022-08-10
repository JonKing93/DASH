function[output] = run(obj, varargin)
%% kalmanFilter.run  Runs a offline ensemble square root Kalman Filter
% ----------
%   output = <strong>obj.run</strong>
%   Runs the Kalman filter. When calculating the Kalman Gain, implements
%   any covariance adjustments implemented by the "inflate", "localize",
%   "blend", and/or "setCovariance" methods. 
% 
%   The output is a scalar struct with various fields. The output always
%   includes the updated ensemble mean ("Amean"), and the calibration ratio
%   ("calibrationRatio"). The output may optionally include variance across
%   the posterior ensemble ("Avar"), percentiles of the posterior ensemble
%   ("Aperc"), and the updated ensemble deviations ("Adev"), depending on
%   the options specified by the "variance", "percentiles", and
%   "deviations", commands. The output will also include the full posterior
%   for any climate indices specified via the "index" command.
%
%   This method uses an ensemble square root Kalman filter, which updates
%   ensemble means separately from the deviations. Updating deviations is
%   more computationally expensive than updating the mean, so the method
%   will only update deviations when necessary. Updating the deviations is
%   necessary when returning posterior variance, percentiles, deviations,
%   or climate indices. Exploratory analyses that only require the ensemble
%   mean can significantly improve run time by not returning these
%   quantities.
%
%   If you would like details on the implementation of the algorithm, or
%   for advice on troubleshooting large state vectors, please see the help
%   text for the kalmanFilter class:
%       >> help kalmanFilter
%
%   output = <strong>obj.run</strong>(..., 'complex', complexResponse)
%   output = <strong>obj.run</strong>(..., 'complex', "error"|"e"|false)
%   output = <strong>obj.run</strong>(..., 'complex', "skip"|"s"|true)
%   Indicates how the method should respond if the adjusted Kalman gain
%   becomes complex valued. This most often occurs because the R uncertainty
%   covariances have negative eigenvalues. This option indicates how the
%   method should respond if the adjusted gain becomes complex valued. If
%   "error"|"e"|false, the method throws an error (this is the default
%   behavior). If "skip"|"s"|true, the method will continue and will use a
%   NaN update for ensemble deviations associated with a complex adjusted
%   Kalman gain. The output will contain the "updatedDeviations" field,
%   which indicates which assimilation time steps received a normal update
%   to the ensemble deviations, and which time steps received a NaN update.
% ----------
%   Inputs:
%       complexResponse (string scalar | scalar logical): Indicates how the
%           method should respond if the adjusted Kalman gain is complex valued
%           ["error"|"e"|false (default)]: Throws an error if the adjusted
%               Kalman gain becomes complex valued
%           ["skip"|"s"|true]: Uses a NaN update for ensemble deviations
%               with a complex valued adjusted Kalman gain
%
%   Outputs:
%       output (scalar struct): Output produced by the Kalman filter. 
%           May include the following fields:
%           .calibrationRatio (numeric matrix [nSite x nTime]): The
%               calibration ratio for each site in each time step.
%           .Amean (numeric matrix [nState x nTime]): The updated ensemble
%               mean in each assimilated time step. This is the best
%               estimate for the updated state vector in each time step.
%           .Adev (numeric 3D array [nState x nMembers x nTime]): The
%               updated ensemble deviations in each time step.
%           .Avar (numeric matrix [nState x nTime]): The variance across
%               the updated ensemble in each time step.
%           .Aperc (numeric 3D array [nState x nPercentiles x nTime]):
%               Percentiles of the updated ensemble in each assimilated
%               time step.
%           .index_<name> (numeric matrix [nMembers x nTime]): The full
%               posterior of a given climate index calculated from the
%               updated ensemble.
%           .updatedDeviations (logical vector [nTime]): Included in the
%               output if the adjusted Kalman gain becomes complex in any
%               assimilation time steps. If the value for a time step is 
%               true, the gain for the time step was real valued and the 
%               ensemble deviations were updated. If the value is false,
%               the gain for the time step was complex valued, and the
%               ensemble deviations were given a NaN update.
%
% <a href="matlab:dash.doc('kalmanFilter.run')">Documentation Page</a>

% Setup
header = "DASH:kalmanFilter:run";
dash.assert.scalarObj(obj, header);

% Require a finalized filter
obj = obj.finalize(true, 'running a Kalman filter', header);
obj = obj.finalizeCovariance;

% Parse the complex error options
complexResponse = dash.parse.nameValue(varargin, "complex", {'error'}, 0, header);
switches = {["error","e"], ["skip","s"]};
allowComplex = dash.parse.switches(complexResponse, switches, 1, ...
                              'complexResponse', 'allowed option', header);
issuedComplexWarning = false;

% Preallocate
output = preallocateOutput(obj, header);

% Determine whether the deviations should be updated
if obj.returnDeviations || numel(obj.calculations)>0
    updateDeviations = true;
else
    updateDeviations = false;
end

% Load and decompose each prior. Also decompose the estimates. Only store
% deviations if required to update deviations or estimate covariance
allSites = 1:obj.nSite;
for p = 1:obj.nPrior    
    try
        if updateDeviations || isempty(obj.Cset)
            [Xmean, Xdev] = dash.math.decompose(obj.loadPrior(p));
            [Ymean, Ydev] = dash.math.decompose(obj.Ye(:,:,p));
        else
            Xmean = dash.math.decompose(obj.loadPrior(p));
            Ymean = dash.math.decompose(obj.Ye(:,:,p));
        end
    catch cause
        priorFailedError(obj, p, cause, header);
    end

    % Get the assimilation time steps associated with the prior. Get the 
    % set of unique covariance matrices used in the prior's time steps
    timesPrior = find(obj.whichPrior==p);
    [whichCov, nCov] = obj.uniqueCovariances(timesPrior);

    % Iterate through covariance matrices. Get the indices of the prior's
    % time steps that are associated with the covariance matrix. Get the
    % assimilation time steps that are referenced by these indices
    for c = 1:nCov
        ct = whichCov == c;
        timesCov = timesPrior(ct);

        % Estimate the covariance matrix
        inputs = {timesCov(1), allSites};
        if isempty(obj.Cset)
            inputs = [inputs, {Xdev, Ydev}]; %#ok<AGROW> 
        end
        [Knum, Ycov] = obj.estimateCovariance(inputs{:});

        % Get the unique set of Kalman gains that are derived from this
        % covariance estimate. Get the Kalman gain to use for each of the
        % covariance matrix's time steps
        sites = ~isnan(obj.Y(:,timesCov));
        [gains, ~, whichGain] = unique(sites', 'rows');
        nGains = size(gains, 1);

        % Iterate through Kalman gains. Get the indices of the covariance
        % matrix's time steps that are associated with the gain. Get the
        % assimilation time steps that are referenced by these indices
        for g = 1:nGains
            gt = find(whichGain == g);
            timesGain = timesCov(gt);

            % Get the sites and R covariance associated with this gain
            s = sites(:, gt(1));
            R = obj.Rcovariance(timesGain(1), s);

            % Compute the Kalman Gain and adjusted gain
            Kdenom = Ycov(s,s) + R;
            K = Knum(:,s) / Kdenom;
            if updateDeviations
                Ka = dash.kalman.adjusted(Knum(:,s), Kdenom, R);

                % Check the adjusted gain is not complex valued. If so,
                % throw error or warn user once
                if ~isreal(Ka)
                    if ~allowComplex
                        complexGainError(obj, timesGain(1), header);
                    elseif ~issuedComplexWarning
                        complexGainWarning;
                        issuedComplexWarning = true;

                        % If permitting the complex gain, initialize the
                        % "updatedDeviations" output
                        output.updatedDeviations = true(obj.nTime, 1);
                    end
                end
            end

            % Initialize values for no update (no observations) case
            nTimeUpdate = numel(timesGain);
            Amean = repmat(Xmean, [1, nTimeUpdate]);
            calibrationRatio = NaN(numel(s), nTimeUpdate);
            if updateDeviations
                Adev = Xdev;
            end

            % If there are sites, update the mean
            if any(s)
                innovation = obj.Y(s,timesGain) - Ymean(s);
                Amean = Amean + K * innovation;
                calibrationRatio = innovation.^2 ./ diag(Kdenom);

                % Update the deviations. Infill with NaN if Ka is complex
                if updateDeviations
                    if isreal(Ka)
                        Adev = dash.kalman.updateDeviations(Adev, Ka, Ydev(s,:));
                    else
                        Adev(:) = NaN;
                        output.updatedDeviations(timesGain) = false;
                    end
                end
            end

            % Perform any calculations on the deviations
            for k = 1:numel(obj.calculations)
                name = obj.calculationNames(k);
                calculator = obj.calculations{k};
                d = calculator.timeDimension;

                % Get the indices in the output where the new calculations
                % should be saved. Time dimension is always the last
                % dimension of calculation output.
                indices = repmat({':'}, 1, d);
                indices{d} = timesGain;
                output.(name)(indices{:}) = calculator.calculate(Adev, Amean);
            end

            % Record output
            output.Amean(:, timesGain) = Amean;
            output.calibrationRatio(s, timesGain) = calibrationRatio;
            if obj.returnDeviations
                output.Adev(:,:,timesGain) = repmat(Adev, 1, 1, nTimeUpdate);
            end
        end
    end
end

end

%% Utilities
function[] = priorFailedError(obj, p, cause, header)

% Too large to fit in memory
if strcmp(cause.identifier, "DASH:ensemble:load:priorTooLarge")
    if p == 1
        name = 'the prior';
    else
        name = sprintf('prior %.f', p);
    end
    link = '<a href="matlab:doc matfile">matfile</a>';
    id = sprintf('%s:arrayTooLarge', header);
    ME = MException(id, ['Cannot run %s because %s is too large ',...
        'to load into memory. Note that that the updates for each state ',...
        'vector element are independent of all the other state vector elements. Thus, ',...
        'you can often circumvent memory issues by dividing the state vector ',...
        'into several smaller pieces, and running the Kalman filter on each ',...
        'piece individually. The built-in %s command can be ',...
        'particularly helpful for saving/loading pieces of large arrays sequentially.'],...
        obj.name, name, link);
    ME = addCause(ME, cause);
    throwAsCaller(ME);

% Other DASH errors - likely an issue with the ensemble's matfile
elseif startsWith(cause.identifier, 'DASH')
    if obj.nPrior == 1
        name = 'the prior';
    else
        name = sprintf('prior %.f', p);
    end
    id = sprintf('%s:priorFailed', header);
    ME = MException(id, 'Cannot run %s because %s failed to load.', obj.name, name);
    ME = addCause(ME, cause);
    throwAsCaller(ME);

% Anything else is an true error, pass it along
else
    rethrow(cause);
end

end
function[output] = preallocateOutput(obj, header)

% Initialize struct
output = struct;

% Include the mean and calibration ratio
try
    output.Amean = NaN(obj.nState, obj.nTime, obj.precision);
    output.calibrationRatio = NaN(obj.nSite, obj.nTime, obj.precision);
    
    % Deviations
    if obj.returnDeviations
        output.Adev = NaN(obj.nState, obj.nMembers, obj.nTime, obj.precision);
    end
    
    % Posterior calculations
    for c = 1:numel(obj.calculations)
        name = obj.calculationNames(c);
        siz = obj.calculations{c}.outputSize(obj.nState, obj.nMembers, obj.nTime);
        output.(name) = NaN(siz, obj.precision);
    end

% Report memory failure
catch cause
    id = sprintf('%s:outputTooLarge', header);
    if obj.returnDeviations
        details = 'You may need to discard the ensemble deviations.';
    else
        details = 'You may want to assimilate the state vector in several smaller pieces.';
    end
    ME = MException(id, 'The requested output is too large to fit in memory. %s', details);
    ME = addCause(ME, cause);
    throwAsCaller(ME);
end

end
function[] = complexGainError(obj, t, header)

details = '';
if obj.nR > 1
    r = obj.whichR(t);
    details = sprintf(['Time step %.f is associated with R covariance ',...
        'matrix %.f. '], t, r);
end

id = sprintf('%s:complexGain', header);
ME = MException(id, ['The adjusted gain for time step %.f is complex valued. ',...
    'This most often occurs when the R covariance matrix for the time step ',...
    'has negative eigenvalues. %sConsider adjusting the eigenvalues of the ',...
    'R covariance matrix, or using a different covariance altogether.'],...
    t, details);
throwAsCaller(ME);

end
function[] = complexGainWarning(header)

id = sprintf('%s:complexGain', header);
warning(id, ['The adjusted Kalman Gain is complex valued in some time steps. ',...
    'The ensemble deviations will receive a NaN update in those time steps. ',...
    'The output struct will include the "updatedDeviations" field, which indicates ',...
    'which assimilation time steps received normal updates, and which time steps ',...
    'received NaN updates. True values indicate a normal update, and false values ',...
    'indicate a NaN update.']);

end
