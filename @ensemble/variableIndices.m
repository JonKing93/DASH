function[v] = variableIndices(obj, variables, scope, header)
%% ensemble.variableIndices  Parse the indices of variables in an ensemble
% ----------
%   v = obj.variableIndices(variables, scope)
%   Parse the indices of variables in an ensemble. Error checks logical or
%   linear indices and locates variable names. Returns linear indices to
%   the specified variables. Throws error if variables are an unrecognized
%   type.
%
%   Interprets inputs within a particular scope. If the scope is used
%   variables, then error checks and parses relative to the variables being
%   used by the ensemble object. If the scope is file variables, error
%   checks and parses relative to the variables saved in the .ens file.
%
%   v = obj.variableIndices(variables, scope, header)
%   Customize header in thrown error IDs
% ----------
%   Inputs:
%       variables: The input being parsed. Either a set of indices or
%           variable names.
%       scope (string scalar | scalar logical): The scope in which to interpret the variables
%           ["used"|"u"|false]: The variables used by the ensemble object
%           ["file"|"f"|true]: The variables saved in the .ens file
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       v (vector, linear indices): The indices of the variables in the
%           .ens file. Note that the output is always in the context of
%           file variables, regardless of the scope of the inputs.
%
% <a href="matlab:dash.doc('ensemble.variableIndices')">Documentation Page</a>

% Default header
if ~exist('header','var') || isempty(header)
    header = "DASH:ensemble:variableIndices";
end

% Parse scope. Get indices if not using file
try
    useFile = ensemble.parseScope(scope, header);
    if ~useFile
        usedIndices = find(obj.use);
    end
    
    % Shortcut for all variables
    if isequal(variables, -1)
        if useFile
            v = 1:obj.nVariables('file');
        else
            v = usedIndices;
        end
        return
    end
    
    % Get names for error messages 
    name = 'variables';
    elementName = 'variable';
    collectionName = obj.name;
    listType = 'variable names';
    
    % Get recognized variables and parse inputs
    recognized = obj.variables(-1, useFile);
    v = dash.parse.stringsOrIndices(variables, recognized, name, elementName,...
           collectionName, listType, header);
    
    % Convert "used" indices to overall variable indices
    if ~useFile
        v = usedIndices(v);
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end