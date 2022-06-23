function[varargout] = uncertainties(obj, R)
%% optimalSensor.uncertainties  Provide error uncertaities for an optimal sensor
% ----------
%   obj = obj.uncertainties(Rvar)
%   Provide error variances for an optimal sensor. The uncertainties should
%   be a numeric vector with one element per observation site. The
%   variances cannot be negative and cannot contain NaN values.
%
%   obj = obj.uncertainties(Rcov)
%   Provide error covariances for an optimal sensor. The unceratinties
%   should be a symmetric matrix with one row and one column per site. The
%   matrix cannot contain NaN values, and the diagonal elements (the error
%   variances) cannot be negative.
%
%   Rvar = obj.uncertainties
%   Rcov = obj.uncertainties
%   Returns the current R uncertainties for an optimal sensor object.
%
%   obj = obj.uncertainties('delete')
%   Deletes the current R error uncertainties from the optimal sensor
%   object.
% ----------
%   Inputs:
%       Rvar (numeric vector [nSite]): Error variances for the observation
%           sites. Must have one row per site. Elements cannot be negative
%           and cannot be NaN.
%       Rcov (numeric matrix [nSite x nSite]): Error covariances for the
%           observation sites. Must have one row and one column per site.
%           Must be a symmetric matrix and may not contain NaN. The
%           diagonal elements cannot be negative.
%
%   Outputs:
%       obj (scalar optimalSensor object): The optimal sensor with updated
%           uncertainties.
%       Rvar (numeric column vector [nSite x 1] | []): The current
%           uncertaintiy variances for the optimal sensor. If there are no
%           uncertainties, returns an empty array.
%       Rcov (numeric matrix [nSite x nSite] | []): The current error
%           covariances for the optimal sensor. If there are no
%           uncertainties, returns an empty array.
%
% <a href="matlab:dash.doc('optimalSensor.uncertainties')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:uncertainties";
dash.assert.scalarObj(obj, header);

% Return
if ~exist('R','var')
    varargout = {obj.R};

% Delete
elseif dash.is.strflag(R) && strcmpi(R, 'delete')
    obj.R = [];
    obj.Rtype = NaN;
    if isempty(obj.Ye)
        obj.nSite = 0;
    end
    varargout = {obj};

% Set. Don't allow empty
else
    if isempty(R)
        emptyUncertaintiesError(obj, header);
    end

    % Detect variances vs covariances. Get sizes
    if isvector(R)
        name = 'R variances';
        iscovariance = false;
        R = R(:);
    else
        name = 'R covariances';
        iscovariance = true;
    end

    % Optionally set sizes
    nSite = size(R, 1);
    if isempty(obj.Ye)
        obj.nSite = nSite;
    end

    % Error check type and size. Require well defined values
    types = ["single", "double"];
    if ~iscovariance
        dash.assert.vectorTypeN(R, types, obj.nSite, name, header);
    else
        dash.assert.matrixTypeSize(R, types, [obj.nSite, obj.nSite], name, header);
    end
    dash.assert.defined(R, 1, name, header);

    % Require positive variances
    if ~iscovariance
        isnegative = R <= 0;
        if any(isnegative)
            negativeVarianceError(R, isnegative, header);
        end

    % Or valid covariances (symmetric with positive diagonals)
    else
        dash.assert.covariances(R, name, header);
    end

    % Set values and return output
    obj.R = R;
    obj.Rtype = double(iscovariance);
    varargout = {obj};
end

end

% Error message
function[] = emptyUncertaintiesError(obj, header)
id = sprintf('%s:emptyUncertainties', header);
ME = MException(id, 'The uncertainties for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
