function[names, values] = nameValueOrCollection(varargs, namesName, valuesName, extraInfo, header)
%% dash.parse.nameValueOrCollection  Parse inputs that are either Name,Value pairs, or collected Name,Value pairs
% ----------
%   [names, values] = dash.parse.nameValueOrCollection(varargs)
%   Parse inputs that are either 1. A set of Name,Value inputs, or 2. A
%   collection of Name,Value inputs in which names are organized in a
%   string vector and values are organized in a cell vector. After parsing,
%   returns names as a string vector and values as a cell vector.
%
%   ... = dash.parse.nameValueOrCollection(varargs, namesName, valuesName, extraInfo, header)
%   Customize thrown error messages and IDs.
% ----------
%   Inputs:
%       varargs (cell vector): The varargin input from the calling function.
%       namesName (string scalar): An identifying name for the names in
%           error messages.
%       valuesName (string scalar): An identifying name for the values in
%           error messages.
%       extraInfo (string scalar): Additional info about Name,Value pairs
%           for error messages.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       names (string vector [nNames]): The names collected in a string vector
%       values (cell vector [nNames]): The values collected in a cell vector
%
% <a href="matlab:dash.doc('dash.parse.nameValueOrCollection')">Documentation Page</a>

% If varargs has 2 elements, require a valid collection
if numel(varargs)==2
    names = dash.assert.strlist(varargs{1}, namesName, header);
    values = dash.parse.inputOrCell(varargs{2}, numel(names), valuesName, header);

% Otherwise, use Name,Value syntax
else
    [names, values] = dash.assert.nameValue(varargs, 0, extraInfo, header);
end

end