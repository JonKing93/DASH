function[] = assertStrFlag( input, name )
%% Checks that an input is a string flag. Returns a customized error
% message if not.
%
% dash.assertStrFlags( input, name )
%
% ----- Inputs -----
%
% input: A variable being checked.
%
% names: The name of the variables to use in error messages. A string.

if ~dash.isstrflag(input)
    error('%s must be a string scalar or character row vector.',name);
end

end