function[tf] = isstrset( str )
%% Tests if an input is either a character row, cellstring, or string

tf = false;
if (ischar(str) && isrow(str)) || iscellstr(str) || isstring(str)
    tf = true;
end

end
