function[tf] = strlist( input )
%% dash.is.strlist  True for a string vector, cellstring vector, or character row vector
% ----------
%   dash.is.strlist(input) 
%   Returns true if input is a string vector, cellstring vector, or char
%   row vector. Otherwise returns false.
% ----------
%   Inputs:
%       input (any data type): The input being tested
%
%   Outputs:
%       tf (scalar logical): True if input is a string vector, cellstring
%           vector, or char row vector.
%
% <a href="matlab:dash.doc('dash.is.strlist')">Documentation Page</a>

tf = false;
if (isvector(input) && dash.is.str(input)) || dash.is.charrow(input)
    tf = true;
end

end