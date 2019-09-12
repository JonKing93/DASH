function[tf] = isstrlist( list )
tf = false;
if isvector( list ) && ( (ischar(list) && isrow(list)) || isstring(list) || iscellstr(list) )
    tf = true;
end
end