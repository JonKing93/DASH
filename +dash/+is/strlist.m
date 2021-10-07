function[tf] = islist( input )
%% Tests if an input is a string vector, cellstring vector, or character
% row vector.
%
% tf = dash.isstrlist( input )
%
% ----- Inputs -----
%
% input: The input being tested.
%
% ----- Outputs -----
%
% tf:  Whether the input is a string list. A scalar logical.

tf = false;
if isvector( input ) && ( (ischar(input) && isrow(input)) || isstring(input) || iscellstr(input) )
    tf = true;
end

end