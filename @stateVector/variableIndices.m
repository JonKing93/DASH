function[v] = variableIndices(obj, variables, allowRepeats, header)
%% stateVector.variableIndices  Parse the indices of variables in a state vector
% ----------
%   v = <strong>obj.variableIndices</strong>(variables)
%   Parse the indices of variables in a state vector. Error checks logical
%   or linear indices and locates variable names. Returns linear indices to
%   the specified variables. Throws error if variables are an unrecognized
%   type.
%
%   v = <strong>obj.variableIndices</strong>(variables, allowRepeats)
%   Specify whether variables can include repeated elements. By default,
%   repeated elements are allowed.
%
%   v = <strong>obj.variableIndices</strong>(variables, allowRepeats, header)
%   Customize the header of thrown error IDs.
% ----------
%   Inputs:
%       variables (any data type): The input being parsed. If valid, should
%           either be array indices or a list of variable names.
%       allowRepeats (scalar logical): Set to true to allow repeat
%           variables. Set to false to require unique variables. Default is true.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       indices (vector, linear indices): The indices of the specified
%           variables in the state vector.
%
% <a href="matlab:dash.doc('stateVector.variableIndices')">Documentation Page</a>

% Shortcut for returning all variables
if isequal(variables, -1)
    v = 1:obj.nVariables;
    return
end

% Defaults
if ~exist('allowRepeats','var') || isempty(allowRepeats)
    allowRepeats = true;
end
if ~exist('header','var') || isempty(header)
    header = "DASH:stateVector:variableIndices";
end

% Get names for error messages
name = 'variables';
elementName = 'variable';
collectionName = obj.name;
listType = 'variable names';

% Parse the inputs
try
    v = dash.parse.stringsOrIndices(variables, obj.variableNames, name, elementName, ...
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