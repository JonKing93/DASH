function[varargout] = localize(obj, wloc, yloc, whichLoc)
%% kalmanFilter.localize  Implement covariance localization for a Kalman Filter
% ----------
%   obj = obj.localize(wloc, yloc)
%   Implements covariance localization for a Kalman Filter. Covariance
%   localization reduces the covariance of observation sites with state
%   vector elements. Often, the localization is implemented so that
%   covariance becomes zero outside of some localization radius. This
%   prevents observation sites from updating distant state vector elements 
%   outside of the radius. Covariance localization is implemented after
%   inflation, but before blending.
%
%   The first input provides the localization weights between the state
%   vector rows and observation sites. It should be a 3D array with one row
%   per state vector element, and one column per observation site. The
%   second input is the localization weights between the observation sites
%   and each other. It should be a 3D array with one row and one column per
%   observation site. Each element along the third dimension of yloc must be a
%   symmetric matrix.
%
%   The two inputs must have the same number of elements along the third
%   dimension. If the third dimension has one element (i.e. both inputs are
%   matrices), then uses the same localization weights in all time steps.
%   Otherwise, the third dimension must have one element per time step
%   (although see the next syntax for relaxing this requirement). The
%   localization weights cannot include NaN values or negative values.
%
%   obj = obj.localize(wloc, yloc, whichLoc)
%   Indicates which set of localization weights to use in each assimilation
%   time step. This syntax allows the number of sets of localization
%   weights to differ from the number of time steps.
%
%   [wloc, yloc, whichLoc] = obj.localize
%   Returns the current localization weights for the Kalman filter.
%
%   obj = obj.localize('reset')
%   Deletes any current localization weights from the Kalman Filter.
% ----------
%   Inputs:
%       wloc (numeric 3D array [nState x nSite x 1|nTime|nLoc]): The
%           localization weights between the state vector elements and
%           observation sites. Cannot include NaN or negative values. If
%           using a single set of localization weights, should have a
%           single element along the third dimension. If the number of
%           elements along the third dimension matches the number of time
%           steps, uses the indicated set of localization weights in each
%           time step. If the number of elements is neither 1 nor the
%           number of time steps, use the whichLoc input to indicate which
%           set of localization weights to use in each time step.
%       yloc (numeric 3D array [nSite x nSite x 1|nTime|nLoc]): The
%           localization weights between the observation sites and one
%           another. Cannot include NaN or negative values. The number of
%           elements along the third dimension must match the number of
%           elements for the wloc input. Each element along the third
%           dimension must be a symmetric matrix.
%       whichLoc (vector, linear indices [nTime]): Indicates which set of
%           localization weights to use in each time step. Must have one
%           element per assimilation time step. Each element is the index
%           of one of the sets of localization weights.
%
%   Outputs:
%       obj (scalar kalmanFilter object): The kalmanFilter object with
%           updated localization weights
%       wloc (numeric 3D array [nState x nSite x 1|nTime|nLoc] | []): The
%           current localization weights between the state vector elements
%           and observation sites. If there are no localization weights,
%           returns an empty array.
%       yloc (numeric 3D array [nSite x nSite x 1|nTime|nLoc] | []): The
%           current localization weights between the observation sites and
%           one another. If there are no localization weights, returns an
%           empty array.
%       whichLoc (vector, linear indices [nTime]): Indicates which set of
%           localization weights to use in each time step. If there is a
%           single set of localization weights, returns an empty array.
%
% <a href="matlab:dash.doc('kalmanFilter.localize')">Documentation Page</a>

% Setup
try
    header = "DASH:kalmanFilter:localize";
    dash.assert.scalarObj(obj, header);
    
    % Return factor
    if ~exist('wloc','var')
        varargout = {obj.wloc, obj.yloc, obj.whichLoc};

    % Delete
    elseif dash.is.strflag(wloc) && strcmpi(wloc, 'reset')
        if exist('yloc','var')
            dash.error.tooManyInputs;
        end

        % Delete and reset time
        obj.wloc = [];
        obj.yloc = [];
        obj.whichLoc = [];
        if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior) ...
                && isempty(obj.whichInflate) && isempty(obj.whichBlend) && isempty(obj.whichSet)
            obj.nTime = 0;
        end
        varargout = {obj};

    % Set. Get default
    else
        if ~exist('whichLoc','var') || isempty(whichLoc)
            whichLoc = [];
        end

        % Don't allow empty. Also don't allow if covariance is set
        if isempty(wloc)
            emptyWlocError(obj, header);
        elseif ~isempty(obj.Cset)
            covarianceSetError(obj, header);
        end

        % Optionally set sizes
        [nRows, nCols, nLoc] = size(wloc, 1:3);
        if isempty(obj.X) && isempty(obj.Cblend)
            obj.nState = nRows;
        end
        if isempty(obj.Y) && isempty(obj.Ye) && isempty(obj.R) && isempty(obj.Cblend)
            obj.nSite = nCols;
        end

        % Initial error check
        siz = [obj.nState, obj.nSite, nLoc];
        dash.assert.blockTypeSize(wloc, ["single","double"], siz, 'wloc', header);
        dash.assert.defined(wloc, 1, 'wloc', header);
        if any(wloc<0, 'all')
            negativeWlocError(wloc, header);
        end

        siz = [obj.nSite, obj.nSite, nLoc];
        dash.assert.blockTypeSize(yloc, ["single","double"], siz, 'yloc', header);
        dash.assert.defined(yloc, 1, 'yloc', header);
        dash.assert.symmetricMatrices(yloc, 'yloc', header);
        if any(yloc<0, 'all')
            negativeYlocError(yloc, header);
        end

        % Note whether allowed to set time
        timeIsSet = true;
        if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior) ...
                && isempty(obj.whichFactor) && isempty(obj.whichBlend)
            timeIsSet = false;
        end

        % Error check and process whichLoc
        obj = obj.processWhich(whichLoc, 'whichLoc', nLoc, ...
                            'sets of localization weights', timeIsSet, false, header);

        % Save and build output
        obj.wloc = wloc;
        obj.yloc = yloc;
        varargout = {obj};
    end

% Minimize error stack
catch ME
    if startsWith(ME.identifier, "DASH")
        throwAsCaller(ME);
    else
        rethrow(ME);
    end
end

end

% Error messages
function[] = emptyWlocError(obj, header)
id = sprintf('%s:emptyLocalization', header);
ME = MException(id, 'The localization weights for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
function[] = covarianceSetError(obj, header)
id = sprintf('%s:covarianceAlreadySet', header);
ME = MException(id, ['You cannot implement localization weights for %s because ',...
    'you already provided a user-specified covariance matrix.'], obj.name);
throwAsCaller(ME);
end
function[] = negativeWlocError(wloc, header)
bad = find(wloc<0, 1);
id = sprintf('%s:negativeWloc', header);
ME = MException(id, 'wloc cannot include negative elements but element %.f is negative', bad);
throwAsCaller(ME);
end
function[] = negativeYlocError(yloc, header)
bad = find(yloc<0, 1);
id = sprintf('%s:negativeYloc', header);
ME = MException(id, 'yloc cannot include negative elements but element %.f is negative', bad);
throwAsCaller(ME);
end