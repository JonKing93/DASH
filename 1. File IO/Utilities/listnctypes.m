function[] = listnctypes
%% Returns a list of valid NetCDF4 data types.
%
% [list] = listnctypes()
% Returns a string array of data types.
%
% listnctypes()
% Outputs the allowed data types to the command window.

list = ["double";"single";"int64";"uint64";"int32";"uint32";"int16"; ...
           "uint16";"int8";"uint8";"char"];
       
if nargout == 0
    disp(list);
end

end