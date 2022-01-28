function[tf] = string(X)

tf = false;
if isstring(X) || iscellstr(X) || (ischar(X) && isrow(X))
    tf = true;
end

end