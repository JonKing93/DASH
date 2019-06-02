function[tf] = isnctype( data )
%% Returns true if data is a type that may be written to a netCDF file.

allowed = ["double";"single";"int64";"uint64";"int32";"uint32";"int16"; ...
           "uint16";"int8";"uint8";"char"];
       
tf = false;
if ismember( class(data), allowed )
    tf = true;
end

end