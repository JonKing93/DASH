function[tf] = strflag(input)
%% dash.is.strflag  True for string scalar or char row vector.
%    
%    dash.is.strflag(A) returns true if A is a string scalar or char
%    row vector and false otherwise.
%
%    <a href="matlab: dash.doc('dash.is.strflag')">Online Documentation</a>

if (ischar(input) && isrow(input)) || (isstring(input) && isscalar(input))
    tf = true;
else
    tf = false;
end

end