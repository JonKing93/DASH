function[tf] = charrow(input)
%% dash.is.charrow  True if an input is a char row vector
% ----------
%   tf = dash.is.charrow(input)
%   Return true if the input is a char row vector. Otherwise, return false.
% ----------
%   Inputs:
%       input (any data type): The input being tested
%   
%   Outputs:
%       tf (scalar logical): True if the input is a char row vector or
%           empty char. False otherwise.
%
% <a href="matlab:dash.doc('dash.is.charrow')">Documentation Page</a>

tf = false;
if ischar(input) && isrow(input)
    tf = true;
end

end