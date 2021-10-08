function[tf] = strlist( input )
%% dash.is.strlist  True for a string vector, cellstring vector, or character row vector
% ----------
%   dash.is.strlist(input) returns true if input is a string vector, cellstring
%   vector, or char row vector. Otherwise returns false.
% ----------
%   Inputs:
%       input: The input being tested
%
%   Outputs:
%       tf (scalar logical): True if input is a string vector, cellstring
%           vector, or char row vector.
%
%   <a href="matlab:dash.doc('dash.is.strlist')">Online Documentation</a>

if isvector(input) && ( (ischar(input) && isrow(input)) || isstring(input) || iscellstr(input) )
    tf = true;
else
    tf = false;
end

end