function[varargout] = setCovariance(obj, C, Ycov, whichSet)
%% kalmanFilter.setCovariance  Directly set the covariance for the Kalman filter
% ----------
%   obj = <strong>obj.setCovariance</strong>(C, Ycov)
%   Directly sets the covariance used by the Kalman Filter. If directly
%   setting the covariance, the Kalman filter will not calculate the
%   covariances between the ensemble and observation estimates. Instead, it
%   will use the directly specified values. This approach can be useful
%   when the default covariance matrices include many NaN elements 
%   (for example, as may happen for deep-time assimilations with changing
%   continental configurations. You cannot implement inflation,
%   localization, or blending when directly setting the covariance.
%
%   The first input provides the covariance between the state vector
%   elements and the observation sites. It should be a3D array with one row
%   per state vector element, and one column per observation site. The
%   second input provides the covariance between the observation sites and
%   one another. It should be a 3D array with one row and one column per
%   observation site. Each element along the third dimension of Ycov must
%   be a symmetric matrix.
%
%   The two inputs must have the same number of elements along the third
%   dimension. If the third dimension has one element (i.e. both inputs are
%   matrices), then the same covariance is used for each assimilation time
%   step. Otherwise, the third dimension must have one element per time
%   step (although see the next syntax for relaxing this requirement). C
%   may contain NaN elements, although the filter will return a NaN update
%   at any state vector rows with a NaN covariance. Ycov cannot include NaN
%   elements.
%
%   obj = <strong>obj.setCovariance</strong>(C, Ycov, whichSet)
%   Indicates which set of covariances to use as the covariance in each
%   assimilated time step. This syntax allows the number of specified
%   covariances to differ from the number of time steps.
%
%   [C, Ycov, whichSet] = <strong>obj.setCovariance</strong>
%   Returns the current set of directly specified covariances for the
%   filter.
%
%   obj = <strong>obj.setCovariance</strong>('reset')
%   Deletes any directly specified covariances from the current filter.
% ----------
%   Inputs:
%       C (numeric 3D array [nState x nSite x 1|nTime|nSet]): The
%           covariance to use between the state vector elements and the
%           observation sites. A 3D array with one row per state vector
%           element, and one column per observation site. If using a single
%           set of covariances, should have a single element along the
%           third dimension. If the number of elements along the third
%           dimension matches the number of time steps, uses the indicated
%           set of covariance in each time step. If the number of elements
%           is neither 1 nor the number of time steps, use the whichSet
%           input to indicate which set of covariances to use in each time
%           step. May include NaN values, but the filter will return a NaN
%           update for state vector elements with NaN covariances.
%       Ycov (numeric 3D array [nSite x nSite x 1|nTime|nSet]): The
%           covariance to use between the observation sites and each other.
%           A 3D array with one site and one column per observation site.
%           The number of elements along the third dimension must match the
%           number of elements for the C input. Cannot include NaN values.
%           Each element along the third dimension must be a symmetric
%           matrix and the diagonal elements must all be positive.
%       whichSet (vector, linear indices [nTime]): Indicates which set of
%           covariances to use in each time step. Must have one element per
%           assimilation time step. Each element is the index of one of the
%           sets of covariances.
%
%   Outputs:
%       obj (scalar kalmanFilter object): The kalmanFilter object with
%           updated covariances
%       C (numeric 3D array [nState x nSite x 1|nTime|nSet] | []): The
%           current directly-set covariances between the state vector
%           elements and observation sites for the filter. If you have
%           not directly set the covariance, returns an empty array.
%       Ycov (numeric 3D array [nSite x nSite x 1|nTime|nSet] | []): The
%           current directly-set covariances between the observation sites
%           and one another for the filter. If you have not directly set
%           the covariance, returns an empty array.
%       whichSet (vector, linear indices [nTime]): Indicates which set of
%           covariances will be used in each time step. If there is a
%           single set of covariances, returns an empty array.
%
% <a href="matlab:dash.doc('kalmanFilter.setCovariance')">Documentation Page</a>

% Setup
try
    header = "DASH:kalmanFilter:blend";
    dash.assert.scalarObj(obj, header);

    % Return
    if ~exist('C','var')
        varargout = {obj.Cset, obj.Yset, obj.whichSet};

    % Delete
    elseif dash.is.strflag(C) && strcmpi(C, 'reset')
        if exist('Ycov','var')
            dash.error.tooManyInputs;
        end

        % Delete. Reset time
        obj.Cset = [];
        obj.Yset = [];
        obj.whichSet = [];
        if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior) ...
                && isempty(obj.whichFactor) && isempty(obj.whichBlend) && isempty(obj.whichSet);
            obj.nTime = 0;
        end
        varargout = {obj};

    % Set. Get default
    else
        if ~exist('whichSet','var') || isempty(whichSet)
            whichSet = [];
        end

        % Don't allow empty. Also don't allow if implementing other
        % covariance methods
        if isempty(C)
            emptySetError(obj, header);
        elseif ~isempty(obj.inflationFactor) || ~isempty(obj.wloc) || ~isempty(obj.Cblend)
            otherCovarianceError(obj, header);
        end

        % Optionally set sizes
        [nRows, nCols, nSet] = size(C, 1:3);
        if isempty(obj.X)
            obj.nState = nRows;
        end
        if isempty(obj.Y) && isempty(obj.Ye) && isempty(obj.R)
            obj.nSite = nCols;
        end

        % Error check
        siz = [obj.nState, obj.nSite, nSet];
        dash.assert.blockTypeSize(C, ["single","double"], siz, 'C', header);
        dash.assert.defined(C, 2, 'C', header);

        siz = [obj.nSite, obj.nSite, nSet];
        dash.assert.blockTypeSize(Ycov, ["single","double"], siz, 'Ycov', header);
        dash.assert.defined(Ycov, 1, 'Ycov', header);
        dash.assert.covariances(Ycov, 'Ycov', header);

        % Note whether allowed to set time
        timeIsSet = true;
        if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior)
            timeIsSet = false;
        end

        % Error check and process whichSet
        obj = obj.processWhich(whichSet, 'whichSet', nSet, 'sets of covariances',...
                                                timeIsSet, false, header);

        % Save and build output
        obj.Cset = C;
        obj.Yset = Ycov;
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
function[] = emptySetError(obj, header)
id = sprintf('%s:emptySet', header);
ME = MException(id, 'The covariance for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
function[] = otherCovarianceError(obj, header)
names = ["inflation","localization","blending"];
used = ~[isempty(obj.inflationFactor), isempty(obj.wloc), isempty(obj.Cblend)];
list = dash.string.list(names(used));

id = sprintf('%s:otherCovarianceMethods', header);
ME = MException(id, ['You cannot directly set the covariance for %s, because you ',...
    'are already implementg covariance %s.'], obj.name, list);
throwAsCaller(ME);
end