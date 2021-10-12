function[string] = list(list)
%% dash.string.list  List the elements of a vector in a formatted sting
% ----------
%   string = dash.string.list(list)  prints the elements of a vector in a
%   string. In the returned string, elements are separated by commas and
%   the word "and" is placed before the final element, if appropriate.
% ----------
%   Inputs:
%       vector (string array | integer array): The list being converted
%           to a string
%
%   Outputs:
%       string (string scalar): The elements of the list formatted as a
%           string
%
%   <a href="matlab:dash.doc('dash.string.list')">Online Documentation</a>

% Get the format specifier
if isstring(list)
    format = """%s""";
elseif isnumeric(list)
    format = "%.f";
end

% Formats for different numbers of elements
nEls = numel(list);
if nEls==0
    string = "";
elseif nEls==1
    string = sprintf(format, list);
elseif nEls==2    
    format = sprintf("%s and %s", format, format);
    string = sprintf(format, list(1), list(2));
else
    formatEnd = sprintf("and %s", format);
    format = sprintf("%s, ", format);
    string = [sprintf(format, list(1:end-1)), sprintf(formatEnd, list(end))];
end
    
end