function[obj] = useVariables(obj, varNames)
%% Specify variables to load from the .ens file. By default, all variables
% are loaded from the file, so this is best used to only load a subset of a
% state vector.
%
% obj = obj.loadVariables(varNames)
% Specifies which variables should be loaded in subsequent calls to
% ensemble.load. 
%
% ----- Inputs -----
%
% varNames: A list of variables in the state vector. A string vector or
%    cellstring vector. Use [] to load all variables (the default).
%
% ----- Outputs -----
%
% obj: The updated ensemble object.

% Check variables. Update. Save
obj = obj.update;
if ~exist('varNames','var') || isempty(varNames)
    varNames = [];
else
    obj.stateVector.checkVariables(varNames);
    varNames = string(varNames);
    varNames = unique(varNames(:));
end
obj.variables = varNames;

end