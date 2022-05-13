function[v] = variableIndices(obj, variables, allowRepeats, header)

% Shortcut for all variables
if isequal(variables, -1)
    v = 1:obj.nVariables;
    return
end

% Defaults
if ~exist('allowRepeats','var') || isempty(allowRepeats)
    allowRepeats = true;
end
if ~exist('header','var') || isempty(header)
    header = "DASH:ensembleMetadata:variableIndices";
end

% Get names for error messages
name = 'variables';
elementName = 'variable';
collectionName = obj.name;
listType = 'variable names';

% Parse the inputs
try
    v = dash.parse.stringsOrIndices(variables, obj.variables_, name, elementName, ...
            collectionName,  listType,  header);
    
    % Check for repeats
    if ~allowRepeats
        dash.assert.uniqueSet(variables, 'Variable', header);
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end