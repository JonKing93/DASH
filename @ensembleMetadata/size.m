function[nState, nEns] = size(obj, vars)
%% Returns the size of a state vector ensemble, or variables in the state
% vector ensemble.
%
% [nState, nEns] = obj.size
% Returns the size of the complete state vector ensemble.
%
% [nEls, nEns] = obj.size(varNames)
% [nEls, nEns] = obj.size(v)
% Returns the size of variables in the state vector ensemble.
%
% ------ Inputs -----
%
% varNames: A list of names of variables in the state vector. A string
%    vector or cellstring vector.
%
% v: A vector of variable indices. Either a vector of linear indices or
%    logical vector with one element per variable in the state vector.
%    Indices should refer to the order of variables as provided by
%    "obj.variableNames"
%
% ----- Outputs -----
%
% nState: The number of state vector elements in the complete state vector.
%    A scalar integer.
%
% nEns: The number of ensemble members in the ensemble. A scalar integer.
%
% nEls: A vector of scalar integers that specifies the number of state
%    vector elements for each specified variable in the state vector.

% If no inputs, return values for the entire ensemble
nEns = obj.nEns;
if ~exist('vars','var') || isempty(vars)
    nState = obj.varLimit(end);
    return;
end

% Otherwise, parse the inputs
listName = 'variable in the state vector';
lengthName = 'the number of variables in the state vector';
v = dash.parseListIndices(vars,'varNames','v',obj.variableNames,listName, lengthName, 1, 'variable names');

% Get nEls
nState = obj.nEls(v);

end