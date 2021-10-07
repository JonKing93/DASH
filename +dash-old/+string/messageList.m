function[str] = messageList( list )
% Returns a numeric of string list as a formatted string for use in
% messages.
%
% str = dash.messageList(list)
%
% ----- Inputs -----
%
% list: The list being formated. Numeric or string.
%
% ----- Outputs -----
%
% str: A formatted output string

% Formatting for sprintf
if isstring(list)
    format = {'"%s"', '"%s" and "%s"', '"%s", ', 'and "%s"'};
elseif isnumeric(list)
    format = {'%.f','%.f and %.f', '%.f, ', 'and %.f'};
end

% Create the outout string
if numel(list)==0
    str = '';
elseif numel(list)==1
    str = sprintf(format{1}, list);
elseif numel(list) == 2
    str = sprintf(format{2}, list(1), list(2));
else
    str = [sprintf(format{3}, list(1:end-1)), sprintf(format{4}, list(end))];
end

end