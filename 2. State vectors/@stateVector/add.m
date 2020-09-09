function[obj] = add(obj, varName, file, autoCouple, overlap)
%% Adds a variable to a stateVector.
%
% obj = obj.add(varName, file)
% Adds a variable to the state vector from a .grid file.
%
% obj = obj.add(varName, file, autoCouple)
% Specify whether the variable should be automatically coupled to other
% variables in the state vector. Default is true.
%
% obj = obj.add(varName, file, autoCouple, overlap)
% Specify whether ensemble members for the variable can use overlapping
% information. Default is false.
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
% overlap: A scalar logical indicating whether ensemble members for the
%    variable can use overlapping data.
%
% ----- Outputs -----
%
% obj: The updated stateVector object.

% Default for autoCouple and overlap
if ~exist('autoCouple','var') || isempty(autoCouple)
    autoCouple = true;
end
if ~exist('overlap','var') || isempty(overlap)
    overlap = false;
end

% Error check, use string internally
dash.assertScalarLogical(overlap, 'overlap');
dash.assertScalarLogical(autoCouple, 'autoCouple');
dash.assertStrFlag(varName, 'varName');
varName = string(varName);

% Check the name is a valid variable name and not a duplicate
obj.checkVariableNames(varName, [], 'varName', 'add a new variable to');

% Create the new variable (error checks file).
newVar = stateVectorVariable(varName, file);
obj.variables = [obj.variables; newVar];
vars(end+1) = varName;

% Update variable coupling and overlap
obj.overlap(end+1, 1) = overlap;
obj.auto_Couple(end+1, 1) = autoCouple;
obj.coupled(end+1, end+1) = true;
if autoCouple
    obj = obj.couple( vars(obj.auto_Couple) );
end

end