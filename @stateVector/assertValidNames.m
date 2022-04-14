function[] = assertValidNames(obj, names, header)
%% stateVector.assertValidNames  Throw error if variable names are not valid
% ----------
%   <strong>obj.assertValidNames</strong>(names)
%   Throws an error if specified variable names are not valid for the
%   current state vector object. Names are not valid if they are
%   1. Not valid MATLAB variable names
%   2. Not unique, or
%   3. Duplicate existing variables in the state vector.
%
%   <strong>obj.assertValidNames</strong>(names, header)
%   Customize header in thrown error IDs.
% ----------
%   Inputs:
%       names (string vector): The variable names being checked
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('stateVector.assertValidNames')">Documentation Page</a>       

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:stateVector:assertValidNames";
end

% Require a vector of unique strings
names = dash.assert.strlist(names, 'Variable names', header);
dash.assert.uniqueSet(names, 'Variable name', header);
nNames = numel(names);

% Check that each new name is a valid matlab variable name
for n = 1:numel(names)
    if ~isvarname(names(n))
        invalidVariableNameError(n, names(n), nNames, header);
    end
end

% Check that the new names don't duplicate existing names
allNames = [names(:); obj.variableNames];
[valid, repeats] = dash.is.uniqueSet(allNames);
if ~valid
    duplicateNameError(obj, repeats, allNames, nNames, header);
end

end

% Error messages
function[] = invalidVariableNameError(index, badName, nNames, header)

inputName = dash.string.elementName(index, 'Variable name', nNames);
link = '<a href="matlab:doc isvarname">isvarname function</a>';

id = sprintf('%s:invalidVariableName', header);
ME = MException(id, ['%s ("%s") is not a valid variable name. Valid names must: 1. begin ',...
    'with a letter, 2. contain only letters, numbers, and underscores, and 3. ',...
    'cannot be a MATLAB keyord. See the %s for additional details.'],...
    inputName, badName, link);
throwAsCaller(ME);
end
function[] = duplicateNameError(obj, repeats, allNames, nNames, header)

inputName = dash.string.elementName(repeats(1), 'Variable name', nNames);
badName = allNames(repeats(1));
link = '<a href="matlab:dash.doc(''stateVector.rename'')">rename the existing variable</a>';

id = sprintf('%s:duplicateVariableName', header);
ME = MException(id, ['%s ("%s") is already the name of a variable in %s. ',...
    'Either use a different name, or %s.'], inputName, badName, obj.name, link);
throwAsCaller(ME);
end
