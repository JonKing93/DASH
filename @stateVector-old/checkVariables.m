function[v, varNames] = checkVariables(obj, varNames)
%% Returns the indices of state vector variables in the stateVector 
% variables array. Returns an error if any variables do not exist. Convert
% variable names to string.
%
% v = obj.checkVariables(varNames)
%
% ----- Inputs -----
%
% varNames: The names of the variables. A string vector or cellstring vector.
%
% ----- Outputs -----
%
% v: The indices in the stateVector variables array.
%
% varNames: The names of variables as strings.

% Option for empty
v = [];
if ~isempty(varNames)
    
    % Check the variables are in the state vector
    listName = sprintf('variable in %s', obj.errorTitle);
    v = dash.assert.strsInList(varNames, obj.variableNames, 'varNames', listName);
    
    % No duplicates
    if numel(v) ~= numel(unique(v))
        error('varNames cannot repeat variable names.');
    end
    
    % Convert to string
    varNames = string(varNames);
end

end