function[names, values] = nameValueOrCollection(names, values, varargs, namesName, valuesName, extraInfo, header)
%% dash.parse.nameValueOrCollection  Parse inputs that are either Name,Value pairs, or collected Name,Value pairs
% ----------
%   [names, values] = dash.parse.nameValueOrCollection(names, values, varargs)
%   Parse inputs that are either 1. A set of Name,Value inputs, or 2. A
%   collection of Name,Value inputs in which names are organized in a
%   string vector and values are organized in a cell vector. After parsing,
%   returns names as a string vector and values as a cell vector.
%
%   ... = dash.parse.nameValueOrCollection(..., namesName, valuesName, extraInfo, header)
%   Customize thrown error messages and IDs.
% ----------
%   Inputs:
%       names (string scalar | string vector [nNames]): Either the first name, or
%           the collection of names as a string vector.
%       values (array | cell vector [nNames]): Either the first value, or
%           the collection of values as a cell vector.
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

% If varargin has elements, use Name,Value syntax
if numel(varargs)>0
    varargs = [{names}, {values}, varargs];
    [names, values] = dash.assert.nameValue(varargs, 0, extraInfo, header);

% Otherwise, require a valid Name,Value collection
else
    names = dash.assert.strlist(names, namesName, header);
    nNames = numel(names);
    values = dash.parse.inputOrCell(values, nNames, valuesName, header);
end

end