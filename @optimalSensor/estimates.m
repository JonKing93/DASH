function[varargout] = estimates(obj, Ye, R)
%% optimalSensor.estimates  Provide observation estimates for an optimal sensor
% ----------
%   obj = obj.estimates(Ye, Rvar)
%   obj = obj.estimates(Ye, Rcov)
%   Provides a set of observations estimates (Ye), and associated
%   uncertainties (R) to an optimal sensor. The estimates should be a
%   numeric matrix. Each row holds the estimates for a particular
%   observation site, and each column holds the estimates for a particular
%   ensemble member. The estimates cannot contain NaN values.
%
%   If providing error variances, the R uncertainties should be a column
%   vector with one row per site. The variances cannot contain NaN values, 
%   and must all be positive. If using error covariances, the R uncertainties
%   should be a symmetric matrix with one row and one column per site. The
%   matrix cannot contain NaN values, and the diagonal elements (the error
%   variances) must all be positive.
%
%   [Ye, Rvar] = obj.estimates
%   [Ye, Rcov] = obj.estimates
%   Returns the current estimates and uncertainties for the optimal sensor.
%
%   obj = obj.estimates('delete')
%   Deletes any current estimates and uncertainties from the optimal sensor.
% ----------
%   Inputs:
%       Ye (numeric matrix [nSite x nMembers]): Proxy estimates for the optimal
%           sensor. A numeric matrix with one row and one column per
%           ensemble member. NaN values are not permitted.
%       Rvar (numeric column vector [nSite]): Error variances for the observation
%           sites. Must have one row per site. May not contain NaN values,
%           and all elements must be positive.
%       Rcov (numeric matrix [nSite x nSite]): Error covariances for the
%           observation sites. Must have one row and one column per site.
%           Must be a symmetric matrix and may not contain NaN. The
%           diagonal elements must all be positive
%
%   Outputs:
%       obj (scalar optimalSensor object): The optimal sensor with an
%           updated prior
%       Ye (numeric matrix [nSite x nMembers] | []): The current estimates
%           for the optimal sensor. If there are no estimates, returns an
%           empty array.
%       Rvar (numeric column vector [nSite] | []): The current uncertainty
%           variances for the optimal sensor. If there are no
%           uncertainties, returns an empty array.
%       Rcov (numeric matrix [nSite x nSite]): The current error covariances
%           for the optimal sensor. If there are no uncertainties, returns
%           an empty array.
%
% <a href="matlab:dash.doc('optimalSensor.estimates')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:estimates";
dash.assert.scalarObj(obj, header);

% Return estimates
if ~exist('Ye','var')
    varargout = {obj.Ye, obj.R};

% If deleting, only allow a single input
elseif dash.is.string(Ye) && strcmpi(Ye, 'delete')
    if exist('R','var')
        dash.error.tooManyInputs;
    end

    % Delete and reset sizes
    obj.Ye = [];
    obj.R = [];
    obj.nSite = 0;
    if isempty(obj.X)
        obj.nMembers = 0;
    end

    % Collect output
    varargout = {obj};

% If setting, don't allow empty estimates or uncertainties
else
    if isempty(Ye)
        emptyEstimatesError(obj, header);
    elseif isempty(R)
        emptyUncertaintiesError(obj, header);
    end

    % Get size of estimates. Set sizes
    [nSite, nCols] = size(Ye, 1:2);
    obj.nSite = nSite;
    if isempty(obj.X)
        obj.nMembers = nCols;
    end

    % Error check estimates
    name = 'Observation estimates (Ye)';
    siz = [NaN, obj.nMembers];
    dash.assert.matrixTypeSize(Ye, ["single","double"], siz, name, header);
    dash.assert.defined(Ye, 1, name, header);

    % Detect R variances vs covariances
    if isvector(R)
        name = 'R variances';
        iscovariance = false;
        nCols = 1;
    else
        name = 'R covariances';
        iscovariance = true;
        nCols = obj.nSite;
    end

    % Error check R type and size
    siz = [obj.nSite, nCols];
    dash.assert.matrixTypeSize(R, ["single","double"], siz, name, header);
    dash.assert.defined(R, 1, name, header);

    % Require positive variances
    if ~iscovariance
        isnegative = R <= 0;
        if any(isnegative)
            negativeVarianceError(R, isnegative, header);
        end

    % Covariances must be a symmetric matrix with positive diagonals
    else
        dash.assert.covariances(R, 'R covariances', header);
    end

    % Save and build output
    obj.Ye = Ye;
    obj.R = R;
    obj.Rtype = double(iscovariance);
    varargout = {obj};
end

end

%% Error messages
function[] = emptyEstimatesError(obj, header)
id = sprintf('%s:emptyEstimates', header);
ME = MException(id, 'The estimates for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
function[] = emptyUncertaintiesError(obj, header)
id = sprintf('%s:emptyUncertainties', header);
ME = MException(id, 'The uncertainties for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
function[] = negativeVarianceError(R, isnegative, header)
bad = find(isnegative, 1);
badValue = R(bad);
id = sprintf('%s:negativeVariance', header);
ME = MException(id, ['R variances must be greater than 0, but element %.f ',...
    'of Rvar (%f) is not.'], bad, badValue);
throwAsCaller(ME);
end