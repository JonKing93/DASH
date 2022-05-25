function[varargout] = prior(obj, X)
%% optimalSensor.prior  Set or return the prior for an optimal sensor
% ----------
%   obj = obj.prior(X)
%   Provide the prior for an optimal sensor directly as a numeric array. 
%   Overwrites any previously specified prior. Each row is a state vector
%   element, and each column is an ensemble member.
%
%   X = obj.prior
%   Returns the current prior for the particle filter object.
%
%   obj = obj.prior('delete')
%   Deletes the current prior from the particle filter object.
% ----------
%   Inputs:
%       X (numeric matrix [nState x nMembers): The prior for the optimal
%           sensor. A numeric matrix with one row per state vector element
%           and one column per ensemble member.
%
%   Outputs:
%       obj (scalar particleFilter object): The particleFilter object with the
%           udpated prior.
%       X (numeric matrix [nState x nMembers]): The current prior for the
%           optimalSensor object. If you have not provided a prior, returns
%           an empty array.
%
% <a href="matlab:dash.doc('optimalSensor.prior')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:prior";
dash.assert.scalarObj(obj, header);

% Return estimates
if ~exist('X','var')
    varargout = {obj.X};

% Delete
elseif dash.is.string(X) && strcmpi(X, 'delete')
    obj.X = [];
    obj.nState = 0;
    if isempty(obj.Ye)
        obj.nMembers = 0;
    end
    varargout = {obj};

% If setting, don't allow an empty prior
else
    if isempty(X)
        emptyPriorError(obj, header);
    end

    % Set sizes
    [nState, nCols] = size(X);
    obj.nState = nState;
    if isempty(obj.Ye)
        obj.nMembers = nCols;
    end

    % Error check prior
    name = 'Prior (X)';
    siz = [NaN, obj.nMembers];
    dash.assert.matrixTypeSize(X, ["single","double"], siz, name, header);
    dash.assert.defined(X, 2, name, header);

    % Save
    obj.X = X;
    varargout = {obj};
end

end