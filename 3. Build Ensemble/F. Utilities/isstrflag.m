function[tf] = isstrflag( str )
%% Tests if an input is a character row vector or string scalar

tf = false;

if ischar(str) && isrow(str)
    tf = true;

elseif isstring(str) && isscalar(str)
    tf = true;
end