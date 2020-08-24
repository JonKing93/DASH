function[varNames] = variableNames(obj)
% Returns the names of the variables in a stateVector object.
%
% varNames = obj.variableNames;
%
% ----- Outputs -----
%
% varNames: A string vector of variable names.

varNames = cell( numel(obj.variables), 1 );
[varNames{:}] = deal(obj.variables.name);
varNames = string(varNames);

end