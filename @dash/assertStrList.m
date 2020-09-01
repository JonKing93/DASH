function[input] = assertStrList(input, name)
%% Checks that an input is a string list. Returns a customized error
% message if not. Optionally returns input as a string data type.
%
% dash.assertStrList(input, name)
%
% input = dash.assertStrList(input, name)
%
% ----- Inputs -----
%
% input: The input being checked
%
% name: The name of a variable being check. A string.
%
% ----- Outputs -----
%
% input: The input as a string data type.

if ~dash.isstrlist(input)
    error('%s must be a string vector or cellstring vector.', name);
end
input = string(input);

end