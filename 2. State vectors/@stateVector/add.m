function[obj] = add(obj, varName, file, autoCouple)
%% Adds a variable to a stateVector.
%
% obj = obj.add(varName, file)
% Adds a variable to the state vector from a .grid file.
%
% obj = obj.add(varName, file, autoCouple)
% Specify whether the variable should be automatically coupled to other
% variables in the state vector. Default is true.
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
% autoCouple: A scalar logical indicating whether to automatically couple
%    the variable to other variables in the state vector (true -- default)
%    or not (false).
%
% ----- Outputs -----
%
% obj: The updated stateVector object.

% Default for autoCouple
if ~exist('autoCouple','var') || isempty(autoCouple)
    autoCouple = true;
end

% Error check, use string internally
dash.assertScalarLogical(autoCouple, 'autoCouple');
dash.assertStrFlag(varName, 'varName');
varName = string(varName);

% Check the name is a valid variable name and not a duplicate
vars = obj.variableNames;
if ismember(varName, vars)
    error('There is already a "%s" variable in %s.', varName, obj.errorTitle);
elseif ~isvarname(varName)
    error('varName must be a valid MATLAB variable name (starts with a letter -- composed only of letters, numbers, and underscores)');
end

% Create the new variable (error checks file).
newVar = stateVectorVariable(varName, file);
obj.variables = [obj.variables; newVar];
vars(end+1) = varName;

% Update variable coupling
obj.auto_Couple(end+1, 1) = autoCouple;
obj.coupled(end+1, end+1) = true;
if autoCouple
    obj = obj.couple( vars(obj.auto_Couple) );
end

end