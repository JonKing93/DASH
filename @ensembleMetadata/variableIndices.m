function[v] = variableIndices(obj, variables, allowRepeats, header)
%% ensembleMetadata.variableIndices  Parse and return indices of variables in a state vector ensemble
% ----------
%   v = obj.variableIndices(variables)
%   Parses the indices of input variables. Returns linear indices to input
%   variables.
%
%   v = obj.variableIndices(variables, allowRepeats)
%   Indicate whether to throw an error when repeated variables occur.
% 
%   v = obj.variableIndices(variables, allowRepeats, header)
%   Customize header in thrown error IDs
% ----------
%   Inputs:
%       variables: The input being parse. A set of variable names or
%           indices of variables in the state vector.
%       allowRepeats (scalar logical): Whether to allow repeated variables
%           (true - default) or to throw an error when repeats occur (false)
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       v (vector, linear indices): The indices of the variables in the
%           state vector.
%
% <a href="matlab:dash.doc('ensembleMetadata.variableIndices')">Documentation Page</a>   

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