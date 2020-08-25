function[varNames] = variableNames(obj)
% Returns the names of the variables in a stateVector object.
%
% varNames = obj.variableNames;
%
% ----- Outputs -----
%
% varNames: A string vector of variable names.

% Default for empty state vector
varNames = strings(0,1);

% Get the variable names
if ~isempty(obj.variables)
    varNames = cell( numel(obj.variables), 1 );
    [varNames{:}] = deal(obj.variables.name);
    varNames = string(varNames);
end

end