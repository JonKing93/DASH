function[input] = assertStrFlag( input, name )
%% Checks that an input is a string flag. Returns a customized error
% message if not. Optionally returns input as a string data type.
%
% dash.assertStrFlag( input, name )
%
% input = dash.assertStrFlag(input, name)
%
% ----- Inputs -----
%
% input: A variable being checked.
%
% name: The name of the variable to use in the error message. A string.
%
% ----- Outputs -----
%
% input: The input as a string data type.

if ~dash.isstrflag(input)
    error('%s must be a string scalar or character row vector.',name);
end
input = string(input);
    
end