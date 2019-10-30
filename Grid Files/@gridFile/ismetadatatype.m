function[tf] = ismetadatatype( value )
% Checks if metadata is a:
% numeric, logical, char, string, cellstring, or datetime

tf = false;
if isnumeric(value) || islogical(value) || ischar(value) || isstring(value) || iscellstring(value) || isdatetime(value)
    tf = true;
end

end