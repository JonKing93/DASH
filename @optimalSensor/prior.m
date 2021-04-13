function[obj] = prior(obj, X)
%% Specify a prior for an optimal sensor test
%
% obj = obj.prior(X)
%
% ----- Inputs -----
%
% X: The prior for an optimal sensor test. A numeric matrix. Each row is a
%    state vector element, each column is an ensemble member.
%
% ----- Outputs -----
%
% obj: The Updated optimalSensor object

%% Error check
assert(isnumeric(X), 'X must be numeric');
assert(ismatrix(X), 'X must be a matrix');
dash.assertRealDefined(X, 'X', true);

% Size check
[nState, nEns] = size(X);
if ~isempty(obj.metricType) && nState~=obj.nState 
    error(['You previously specified a test metric for a prior with %.f ',...
        'state vector elements (rows), but this prior has %.f rows'], obj.nState, nState);
elseif obj.hasPSMs && nState~=obj.nState
    error(['You previously specified PSMs for a prior with %.f state vector ',...
        'elements (rows), but this prior has %.f rows.'], obj.nState, nState);
elseif ~isempty(obj.Ye) && nEns~=obj.nEns
    error(['You previously specified estimates for a prior with %.f ensemble ',...
        'members (columns), but this prior has %.f columns.'], obj.nEns, nEns);
end

% Save
obj.X = X;
obj.nState = nState;
obj.nEns = nEns;

end