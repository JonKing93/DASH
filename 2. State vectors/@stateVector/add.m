function[obj] = add(obj, varName, file)
%% Adds a variable to a stateVector.
%
% obj = obj.add(varName, file)
% Adds a variable to the state vector from a .grid file.
%
% ----- Inputs -----
% 
% varName: A name to identify the variable in the state vector. A string
%    scalar or character row vector. Use whatever name you find meaningful,
%    does not need to match the name of anything in the .grid file. Cannot
%    repeat the name of a variable already in the stateVector object.
%
% file: The name of the .grid file that holds data for the variable. A
%    string scalar or character row vector.
%
% ----- Outputs -----
%
% obj: The updated stateVector object.

% Error check, use string internally
dash.assertStrFlag(varName, 'varName');
varName = string(varName);

% Check the name is not a duplicate
currentNames = obj.variableNames;
if ismember(varName, currentNames)
    error('There is already a "%s" variable in %s.', varName, obj.errorTitle);
end

% Create the stateVectorVariable object. (Error checks varName and file)
newVar = stateVectorVariable(varName, file);
obj.variables = [obj.variables; newVar];

end