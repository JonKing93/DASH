function[obj] = loadVariables(obj, varNames)
%% Specify which variables to load
%
% obj = obj.loadVariables(varNames)
% Specifies which variables should be loaded in subsequent calls to
% ensemble.load.
%
% ----- Inputs -----
%
% varNames: A list of variables in the state vector. A string vector or
%    cellstring vector.
%
% ----- Outputs -----
%
% obj: The updated ensemble object.

% Check variables. Update. Save
obj = obj.update;
obj.meta.checkVariables(varNames);
obj.variables = unique(varNames(:));

end