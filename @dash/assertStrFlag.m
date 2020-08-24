function[] = assertStrFlag( input, name )
%% Checks that an input is a string flag. Returns a customized error
% message if not.
%
% dash.assertStrFlag( input, name )
%
% ----- Inputs -----
%
% input: A variable being checked.
%
% name: The name of the variable to use in the error message. A string.

if ~dash.isstrflag(input)
    error('%s must be a string scalar or character row vector.',name);
end

end