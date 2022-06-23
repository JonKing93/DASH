function[varargout] = estimates2(obj, Ye)
%% optimalSensor.estimates  Provide observation estimates for an optimal sensor
% ----------
%   obj = obj.estimates(Ye)
%   Provide a set of observation estimates (Ye) to an optimal sensor. The
%   estimates should be a numeric matrix. Each row holds the estimates for
%   a particular observation site, and each column holds the estimates for
%   a particular ensemble members. The estimates cannot contain NaN values.
%
%   Ye = obj.estimates
%   Returns the current estimates for an optimal sensor object.
%
%   obj = obj.estimates('delete')
%   Deletes any current estimates from the optimal sensor.
% ----------
%   Inputs:
%       Ye (numeric matrix [nSite x nMembers]): Proxy estimates for the optimal
%           sensor. A numeric matrix with one row and one column per
%           ensemble member. NaN values are not permitted.
%
%   Outputs:
%       obj (scalar optimalSensor object): The optimal sensor with an
%           updated prior
%       Ye (numeric matrix [nSite x nMembers] | []): The current estimates
%           for the optimal sensor. If there are no estimates, returns an
%           empty array.
%
% <a href="matlab:dash.doc('optimalSensor.estimates')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:estimates";
dash.assert.scalarObj(obj, header);

% Return
if ~exist('Ye','var')
    varargout = {obj.Ye};

% Delete
elseif dash.is.string(Ye) && strcmpi(Ye, 'delete')
    obj.Ye = [];
    if isempty(obj.J)
        obj.nMembers = 0;
    end
    if isempty(obj.R)
        obj.nSite = 0;
    end
    varargout = {obj};

% Set
else
    if isempty(Ye)
        emptyEstimatesError(obj, header);
    end

    % Set sizes
    [nSite, nMembers] = size(Ye, 1:2);
    if isempty(obj.J)
        obj.nMembers = nMembers;
    end
    if isempty(obj.R)
        obj.nSite = nSite;
    end

    % Error check type and size. Require well defined values
    siz = [obj.nSite, obj.nMembers];
    dash.assert.matrixTypeSize(Ye, ["single","double"], siz, 'Ye', header);
    dash.assert.defined(Ye, 1, 'Ye', header);

    % Set and return output
    obj.Ye = Ye;
    varargout = {obj};
end

end

% Error messages
function[] = emptyEstimatesError(obj, header)
id = sprintf('%s:emptyEstimates', header);
ME = MException(id, 'The estimates for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end