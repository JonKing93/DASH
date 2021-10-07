function[tf] = strlist( input )
%% Test if input is a string vector, cellstring vector, or character row vector
%
% tf = dash.is.strlist(input)
% Returns true if the input is a string list. Otherwise, returns false.
%
% ----- Inputs -----
%
% input: The input being tested.
%
% ----- Outputs -----
%
% tf: A scalar logical. True if the input is a string list, otherwise false

if isvector(input) && ( (ischar(input) && isrow(input)) || isstring(input) || iscellstr(input) )
    tf = true;
else
    tf = false;
end

end