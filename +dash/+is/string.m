function[tf] = string(X)

tf = false;
if isstring(X) || iscellstr(X) || (ischar(X) && (isrow(X)||isempty(X)))
    tf = true;
end

end