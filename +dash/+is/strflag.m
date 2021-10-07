function[tf] = strflag( input )
%% Test if input is a string scalar or character row vector
%
% tf = dash.is.strflag(input)
% Returns true if the input is a string flag. Otherwise, returns false
%
% ----- Inputs -----
%
% input: The input being tested.
%
% ----- Outputs -----
%
% tf: A scalar logical. True if the input is a string flag, otherwise false

if (ischar(input) && isrow(input)) || (isstring(input) && isscalar(input))
    tf = true;
else
    tf = false;
end

end