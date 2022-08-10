function[varargout] = estimate(F, X, varargin)
%% PSM.estimate  Compute observation estimates by applying forward models to a state vector ensemble
% ----------
%   Ye = PSM.estimate(F, X)
%   Ye = PSM.estimate(F, ens)
%   Computes observation estimates for a set of PSMs / forward models. For
%   each PSM, uses the PSM's rows to extract forward model inputs from the
%   state vector ensemble. These inputs are used to run the PSM, and the
%   PSM outputs are added to the output array of observation estimates.
%
%   Forward models should be provided either as a cell vector, where each
%   element holds a scalar PSM object. If all the PSM objects are the same
%   type of PSM, you may alternatively provide the PSM objects directly as
%   PSM vector. Each PSM object is used to produce estimates for a
%   particular observation site. Each row of the output array Ye holds the
%   estimates for a particular PSM / observation site. The order of rows of
%   Ye will match the order of input PSMs.
%
%   You can provide the state vector ensemble either directly as a numeric
%   array, or as an ensemble object. If using a numeric array, the rows are
%   treated as state vector elements and the columns are ensemble members.
%   Any elements along the third dimension are treated as individual
%   ensembles in an evolving set. If using an ensemble object, the object
%   may implement either a static or an evolving ensemble. The number of
%   columns of Ye will match the number of ensemble members, and the number
%   of elements along the third dimension of Ye will match the number of
%   evolving ensembles.
%
%   The method uses PSM rows to extract forward model inputs from the state
%   vector ensemble. Thus, you must call the "rows" command on each input
%   PSM object before using the "estimate" command. If any of the PSM objects defines
%   different rows for different ensemble members, then all of the PSM
%   objects must either 1. Define rows for the same number of ensemble
%   members, or 2. Use the same rows for all ensemble members. Likewise, if
%   any of the PSM objects defines different rows for different ensembles
%   in an evolving set, then all of the PSM objects must either 1. Define
%   rows for the same number of evolving ensembles, or 2. Use the same rows
%   for all evolving ensembles.
%
%   If a PSM fails, the method issues a warning that the PSM failed in the
%   console. The Ye values for the PSM will all be NaN.
%
%   [Ye, R] = PSM.estimate(...)
%   Also estimates R error-variances from the PSMs whenever possible. Each
%   row of the output array holds the estimated R error-variances for a
%   particular site. If a forward model does not have the ability to
%   estimate R variances, the R variances for the observation site will all
%   be NaN. If a PSM fails, the R values for the PSM will all be NaN.
%
%   ... = PSM.estimate(..., 'fail', failureResponse)
%   ... = PSM.estimate(..., 'fail', 0|'e'|'error')
%   ... = PSM.estimate(..., 'fail', 1|'s'|'skip')
%   ... = PSM.estimate(..., 'fail', 2|'w'|'warn')
%   Indicate how the method should respond when a PSM fails to run. If
%   0|'e'|'error', throws an error when a PSM fails. If 1|'s'|'skip', skips
%   over the failed PSM. If 2|'w'|'warn', skips over the failed PSM and
%   displays a warning in the console.
%
%   ... = PSM.estimate(..., 'status', reportStatus)
%   [status, Ye, R] = PSM.estimate(..., 'status', true|'r'|'report')
%   [Ye, R] = PSM.estimate(..., 'status', false|'d'|'discard')
%   Indicate if the method should return a status report for each of the
%   PSMs. The status report returns additional information about any PSMs
%   that failed to run. This option allows users to obtain more information
%   for troubleshooting PSMs that have failed. If true|'r'|'report',
%   returns a status report as the first output of the method. The status
%   report is a struct with two fields: ".failed" and ".cause". The
%   ".failed" field whether each PSM ran successfully or failed. If the PSM
%   ran successfully, .failed is 0 for the PSM. Otherwise, .failed is an
%   integer that reports the type of failure that occurred. The ".cause"
%   field reports the errors that caused any PSMs to failed. This field is
%   a cell vector with one element per PSM. If the PSM ran successfully,
%   the associated element is empty. If the PSM failed, the associated
%   element contains the error that caused the failure.
% ----------
%   Inputs:
%       F (cell vector | PSM vector [nSite]): The forward models for the
%           observation sites. Either a cell vector or a PSM vector with
%           one element per observation site. If a cell vector, each
%           element must hold a scalar PSM object. The PSM objects must all
%           have previously used the "rows" command to define the state
%           vector rows that hold the forward model inputs. 
% 
%           If any PSM objects define different rows for different ensemble
%           members, then all PSM objects must either 1. Define rows for
%           the same number of ensemnble members, or 2. Use the same rows
%           for all ensemble members. If any PSM object define different
%           rows for different ensembles in an evolving set, then all PSM
%           objects must either 1. Define rows for the same number of
%           evolving ensembles, or 2. Use the same rows for all evolving
%           ensembles.
%       X (numeric 3D array [nState x nMembers x nEvolving]): The state
%           vector ensemble provided directly as a numeric array. Each row
%           is a state vector element, each column is an ensemble member,
%           and each element along the third dimension is an ensemble in an
%           evolving set.
%       ens (scalar ensemble object): The state vector ensemble provided as
%           an ensemble object. May implement either a static or an
%           evolving ensemble.
%       failureResponse (string scalar | numeric scalar): Indicates how the
%           method should respond when a PSM fails to run.
%           [0|'e'|'error']: Throw an error
%           [1|'s'|'skip']: Skip the failed PSM, but do not issue a warning in the console
%           [2|'w'|'warn']: Issue a warning in the console and skip the PSM
%       reportStatus (string scalar | scalar logical): Indicates whether
%           the method should return a status report for the PSMs.
%           [true|'r'|'report']: Return a status report as the first output
%           [false|'d'|'discard']: Do not return a status report
%
%   Outputs:
%       Ye (numeric 3D array [nSite x nMembers x nEvolving]): The
%           observation estimates generated by applying the forward models
%           to the state vector ensemble.
%       R (numeric 3D array [nSite x nMembers x nEvolving]): The R error
%           variances estimated by the forward models.
%       status (scalar struct): A status report for the PSMs
%           .failed (numeric vector [nSite]): Indicates the status of each
%               forward model run
%               [0]: The forward model ran successfully
%               [1]: The inputs for the forward model failed to load
%               [2]: The forward model issued an error while running
%               [3]: The Ye outputs from the forward model were not valid
%               [4]: The R uncertainties from the forward model were not valid
%           .cause (cell vector [nSite] {[] | scalar MException}): Reports
%               the error that caused a PSM to fail. If the PSM ran
%               successfully, the associated element is empty.
%
% <a href="matlab:dash.doc('PSM.estimate')">Documentation Page</a>

% Initial error check of forward models
header = "DASH:PSM:estimate";
dash.assert.vectorTypeN(F, ["cell","PSM.Interface"], [], 'F', header);
nSite = numel(F);

% If cell forward models, require each element to hold a scalar PSM.
% Otherwise, convert PSM array to cell
if iscell(F)
    for s = 1:nSite
        name = sprintf('Element %.f of F', s);
        dash.assert.scalarType(F{s}, 'PSM.Interface', name, header);
    end
else
    F = num2cell(F);
end

% Require ensemble is a numeric array or scalar ensemble object.
dash.assert.type(X, ["single","double","ensemble"], [], header);

% Ensemble object. Require scalar
if isa(X, 'ensemble')
    isobject = true;
    ens = X;
    dash.assert.scalarType(ens, [], 'ens', header);

    % Get sizes
    nState = ens.nRows;
    nMembers = ens.nMembers;
    nEvolving = ens.nEvolving;

    % Validate the ensemble object
    try
        [~, ~, precision] = ens.validateMatfile;
    catch cause
        objectFailedError(ens, cause, header);
    end

    % Record members in case of iterated loading
    members = ens.members;

% Numeric. Require 3D array and get sizes
else
    isobject = false;
    dash.assert.blockTypeSize(X, [], [], 'X', header);
    [nState, nMembers, nEvolving] = size(X, 1:3);
end

% Parse the optional inputs
flags = ["fail", "status"];
defaults = {'warn', false};
[failureResponse, reportStatus] = dash.parse.nameValue(...
                                    varargin, flags, defaults, 2, header);

% Parse switches
switches = {["f","fail"], ["s","skip"], ["w","warn"]};
failureResponse = dash.parse.switches(failureResponse, switches, 1, ...
                            'failure response', 'recognized option', header);
switches = {["d","discard"], ["r","report"]};
reportStatus = dash.parse.switches(reportStatus, switches, 1, 'report status',...
                                                'recognized option', header);

% Require each forward model has rows.
for s = 1:nSite
    rows = F{s}.rows_;
    [nMembersPSM, nEvolvingPSM] = size(rows, 2:3);
    if isempty(rows)
        noRowsError(F, s, header);

    % Row elements must be linear indices for the state vector
    elseif max(rows) > nState
        rowsTooLargeError(F, s, rows, nState, header);

    % Require correct number if using different rows for members or evolving
    elseif nMembersPSM~=1 && nMembersPSM~=nMembers
        wrongNumberMembersError(F, s, nMembersPSM, nMembers, header);
    elseif nEvolvingPSM~=1 && nEvolvingPSM~=nEvolving
        wrongNumberEnsemblesError(F, s, nEvolvingPSM, nEvolving, header);
    end
end

% Check outputs and note whether to calculate R
if reportStatus
    maxOut = 3;
else
    maxOut = 2;
end
if nargout > maxOut
    dash.error.tooManyOutputs;
elseif nargout == maxOut
    calculateR = true;
else
    calculateR = false;
end

% Preallocate
Ye = NaN(nSite, nMembers, nEvolving);
if calculateR
    R = zeros(nSite, nMembers, nEvolving);
end
if reportStatus
    status = struct('failed', NaN(nSite,1));
    status.cause = cell(nSite, 1);
end

% Attempt to generate estimates for each forward model.
for s = 1:nSite
    try
        psmStatus = 1;

        % Start by getting the rows and size of rows
        model = F{s};
        rows = model.rows_;
        [nRows, nMembersPSM, nEvolvingPSM] = size(rows, 1:3);

        % Extract model inputs from numeric array. Propagate rows
        if ~isobject
            if nMembersPSM == 1
                rows = repmat(rows, [1 nMembers 1]);
            end
            if nEvolvingPSM == 1
                rows = repmat(rows, [1 1 nEvolving]);
            end

            % Extract data at indices
            inputSize = [nRows, nMembers, nEvolving];
            subscripts = dash.indices.subscript(inputSize);
            ensembleSize = [nState, nMembers, nEvolving];
            indices = sub2ind(ensembleSize, rows(:), subscripts{2}, subscripts{3});
    
            Xpsm = X(indices);
            Xpsm = reshape(Xpsm, inputSize);

        % Ensemble object. Load static rows directly
        else
            if nMembersPSM==1 && nEvolvingPSM==1
                Xpsm = ens.loadRows(rows);

            % Otherwise, need to iterate through load calls. Preallocate
            else
                Xpsm = NaN([nRows, nMembers, nEvolving], precision);

                % Changing members, static ensemble
                if nMembersPSM>1 && nEvolvingPSM==1
                    for m = 1:nMembers
                        ensMember= ens.useMembers(members(m));
                        Xpsm(:,m,:) = ensMember.loadRows(rows(:,m));
                    end

                % Static members, changing ensemble
                elseif nMembersPSM==1 && nEvolvingPSM>1
                    for e = 1:nEvolving
                        Xpsm(:,:,e) = ens.loadRows(rows(:,:,e), e);
                    end

                % Changing members, changing ensemble
                else
                    for m = 1:nMembers
                        ensMember = ens.useMembers(members(m));
                        for e = 1:nEvolving
                            Xpsm(:,m,e) = ensMember.loadRows(rows(:,m,e), e);
                        end
                    end
                end
            end
        end

        % Run the model on the inputs.
        psmStatus = 2;
        if calculateR && model.estimatesR
            [Ypsm, Rpsm] = model.estimate(Xpsm);
        else
            Ypsm = model.estimate(Xpsm);
        end

        % Get a name for the PSM
        name = psmName(s, model);

        % Error check the estimates
        psmStatus = 3;
        Yname = sprintf('Ye estimates for %s', name);
        siz = [1, nMembers, nEvolving];
        dash.assert.blockTypeSize(Ypsm, 'numeric', siz, Yname, header);

        % Error check the R uncertainties
        if calculateR && model.estimatesR
            psmStatus = 4;
            Rname = sprintf('R uncertainties for %s', name);
            dash.assert.blockTypeSize(Rpsm, 'numeric', siz, Rname, header);
        end

        % Record estimates and R
        Ye(s,:,:) = Ypsm;
        if calculateR && model.estimatesR
            R(s,:,:) = Rpsm;
        end
    
    % Respond to failed PSMs
    catch cause
        if failureResponse == 0
            psmFailedError(model, s, cause, header);
        elseif failureResponse == 2
            psmFailedWarning(model, s, header);
        end

        % Record the status of a failed PSM
        if reportStatus
            status.failed(s) = psmStatus;
            status.cause{s} = cause;
        end
    end
end

% Build output
if reportStatus
    varargout = {status, Ye};
else
    varargout = {Ye};
end
if calculateR
    varargout = [varargout, R];
end

end

%% Utilties
function[name] = psmName(s, model)
name = sprintf('PSM %.f', s);
if ~strcmp(model.label, "")
    name = sprintf('%s ("%s")', name, model.label);
end
end


%% Error messages
function[] = objectFailedError(ens, cause, header)
id = sprintf('%s:invalidEnsemble', header);
ME = MException(id, 'Cannot calculate estimates because %s is not valid.', ens.name);
ME = addCause(ME, cause);
throwAsCaller(ME);
end
function[] = noRowsError(F, s, header)
name = psmName(s, F{s});
id = sprintf('%s:noRows', header);
ME = MException(id, ['%s does not have state vector rows. Please use the ',...
    '"rows" command to provide rows for the PSM.'], name);
throwAsCaller(ME);
end
function[] = wrongNumberMembersError(F, s, nPSM, nMembers, header)
name = psmName(s, F{s});
id = sprintf('%s:wrongNumberMembers', header);
ME = MException(id, ['%s defines state vector rows for %.f ensemble members, but the ',...
    'input ensemble has %.f members.'], name, nPSM, nMembers);
throwAsCaller(ME);
end
function[] = wrongNumberEnsemblesError(F, s, nPSM, nEvolving, header)
name = psmName(s, F{s});
id = sprintf('%s:wrongNumberEnsembles', header);
ME = MException(id, ['%s defines state vector rows for %.f evolving ensembles, ',...
    'but the input ensemble has %.f evolving ensembles.'], name, nPSM, nEvolving);
throwAsCaller(ME);
end
function[] = psmFailedError(model, s, cause, header)
name = psmName(s, model);
id = sprintf('%s:psmFailed', header);
ME = MException(id, '%s did not run successfully', name);
ME = addCause(ME, cause);
throwAsCaller(ME);
end
function[] = psmFailedWarning(model, s, header)
name = psmName(s, model);
id = sprintf('%s:psmFailed', header);
warning(id, '%s did not run successfully', name)
end
