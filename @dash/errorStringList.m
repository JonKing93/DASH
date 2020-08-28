function[str] = errorStringList( strings )
%% Returns a list of strings as a formatted string for use in an error message.
%
% str = dash.errorStringList( strings )
%
% ----- Inputs -----
%
% strings: A list of strings.
%
% ----- Ouputs -----
%
% str: A formatted output string.

if numel(strings)==0
    str = '';
elseif numel(strings)==1
    str = sprintf('"%s"',strings);
elseif numel(strings)==2
    str = sprintf('"%s" and "%s"', strings(1), strings(2));
else
    str = [sprintf('"%s", ', strings(1:end-1)), sprintf('and "%s"', strings(end))];
end

end
    