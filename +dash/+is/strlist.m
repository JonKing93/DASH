function[tf] = strlist( input )
%% dash.is.strlist  True for a string vector, cellstring vector, or character row vector
%
%   dash.is.strlist(A) returns true if A is a string vector, cellstring
%   vector, or char row vector. Otherwise returns false.
%
%   <a href="matlab:dash.doc('dash.is.strlist')">Online Documentation</a>

if isvector(input) && ( (ischar(input) && isrow(input)) || isstring(input) || iscellstr(input) )
    tf = true;
else
    tf = false;
end

end