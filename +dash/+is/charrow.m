function[tf] = charrow(input)
%% dash.is.charrow  True if an input is a char row vector or empty char
% ----------
%   tf = dash.is.charrow(input)
%   Return true if the input is either a char row vector, or an empty char.
%   Otherwise, return false.
% ----------
%   Inputs:
%       input: The input being tested
%   
%   Outputs:
%       tf (scalar logical): True if the input is a char row vector or
%           empty char. False otherwise.
%
% <a href="matlab:dash.doc('dash.is.charrow')">Documentation Page</a>

tf = false;
if ischar(input) && (isrow(input) || isempty(input))
    tf = true;
end

end