function[tf] = str(input)
%% dash.is.str  True if an input is string or cellstring

tf = false;
if isstring(input) || iscellstr(input)
    tf = true;
end

end