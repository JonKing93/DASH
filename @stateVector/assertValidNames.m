function[] = assertValidNames(obj, names, header)

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
error(id, ['%s ("%s") is not a valid variable name. Valid names must: 1. begin ',...
    'with a letter, 2. contain only letters, numbers, and underscores, and 3. ',...
    'cannot be a MATLAB keyord. See the %s for additional details.'],...
    inputName, badName, link);
end
function[] = duplicateNameError(obj, repeats, allNames, nNames, header)

inputName = dash.string.elementName(repeats(1), 'Variable name', nNames);
badName = allNames(repeats(1));
link = '<a href="matlab:dash.doc(''stateVector.rename'')">rename the existing variable</a>';

id = sprintf('%s:duplicateVariableName', header);z
error(id, ['%s ("%s") is already the name of a variable in %s. ',...
    'Either use a different name, or %s.'], inputName, badName, obj.name, link);
end
