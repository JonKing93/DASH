function[tf] = isnctype( data )
%% Returns true if data is a type that may be written to a netCDF file.

nctype = listnctypes;
       
tf = false;
if ismember( class(data), nctype )
    tf = true;
end

end