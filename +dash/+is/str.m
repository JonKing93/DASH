function[tf] = str(input)
%% dash.is.str  True if an input is string or cellstring
% ----------
%   tf = dash.is.str(input)
%   Returns true if the input is a string or cellstring. Otherwise, returns
%   false.
% ----------
%   Inputs:
%       input (any data type): The input being tested
%
%   Outputs:
%       tf (scalar logical): True if the input is a string or cellstring.
%           Otherwise false.
%
% <a href="matlab:dash.doc('dash.is.str')">Documentation Page</a>

tf = false;
if isstring(input) || iscellstr(input)
    tf = true;
end

end