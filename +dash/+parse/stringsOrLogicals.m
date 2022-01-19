function[logicals] = stringsOrLogicals(input, trueStrings, falseStrings, name, stringsName, header)
%% dash.parse.stringOrLogical  Parse inputs that may either be logicals or strings associated with logicals
% ----------
%   switches = dash.parse.stringsOrLogicals(input, trueStrings, falseStrings)
%   Parses an input that may either consist of logicals or strings
%   associated with logical (true/false) values. Returns the input as the
%   appropriate logical types. Throws an error if the input is neither
%   string nor logical, or if the input contains unrecognized strings.
%
%   switches = dash.parse.stringsOrLogicals(..., name, header)
%   Customize thrown error messages.
% ----------
%   Inputs:
%       input: The input being parsed
%       trueStrings (string vector): The list of strings associated with true
%       falseStrings (string vector): The list of strings associated with false
%       name (string scalar): The name of the input being checked.
%       stringsName (string scalar): The name of the list of allowed strings
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       logicals (logical): The logical values associated with the input
%
% <a href="matlab:dash.doc('dash.parse.stringsOrLogicals')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('stringsName','var') || isempty(stringsName)
    stringsName = "allowed string";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:parse:stringOrLogicalSwitches";
end

% Strings
if dash.is.strlist(input)
    input = string(input);
    nTrue = numel(trueStrings);
    allowedStrings = [trueStrings(:); falseStrings(:)];
    
    k = dash.assert.strsInList(input, allowedStrings, name, stringsName, header);
    logicals = k<=nTrue;

% Logical
elseif islogical(input)
    logicals = input;

% Anything else
else
    id = sprintf('%s:inputNeitherStringNorLogical', header);
    error(id, '%s must be either a string or logical data type', name);
end

end