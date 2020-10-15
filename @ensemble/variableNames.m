function[varNames] = variableNames(obj)
%% Returns the names of the variables in the .ens file.
%
% varNames = obj.variableNames
%
% ----- Outputs -----
%
% varNames: The names of the variables in the .ens file. A string vector.

obj = obj.update;
varNames = obj.metadata.variableNames;

end