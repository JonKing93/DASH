function[list] = list(list, conjunction)
%% dash.string.list  List the elements of a vector in a formatted sting
% ----------
%   list = dash.string.list(list)  
%   Prints the elements of a vector in a string. In the returned string, 
%   elements are separated by commas and the word "and" is placed before 
%   the final element, if appropriate.
%
%   list = dash.string.list(list, conjunction)
%   Specify the conjunction to use before the final element in a list. Uses
%   "and" by default.
% ----------
%   Inputs:
%       vector (string array | integer array): The list being converted
%           to a string
%       conjunction (string scalar): A conjunction placed before the final
%           element of the list, if appropriate.
%
%   Outputs:
%       list (char row vector): The elements of the list formatted as a
%           single char string.
%
% <a href="matlab:dash.doc('dash.string.list')">Documentation Page</a>

% Default
if ~exist('conjunction','var') || isempty(conjunction)
    conjunction = "and";
end

% Get the format specifier and convert char/cellstring to string
if dash.is.strlist(list)
    format = '"%s"';
    list = string(list);
elseif isnumeric(list)
    format = '%.f';
end

% Formats for different numbers of elements
nEls = numel(list);
if nEls==0
    list = '';
elseif nEls==1
    list = sprintf(format, list);
elseif nEls==2    
    format = sprintf('%s %s %s', format, conjunction, format);
    list = sprintf(format, list(1), list(2));
else
    formatEnd = sprintf('%s %s', conjunction, format);
    format = sprintf('%s, ', format);
    list = [sprintf(format, list(1:end-1)), sprintf(formatEnd, list(end))];
end
    
end