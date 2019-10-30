function[X] = read( obj, start, count, stride )
% Reads data from a NetCDF file in a gridFile.
%
% Really just a standing call to ncread
try
    X = ncread( obj.filepath, obj.varName, start, count, stride );
catch ME
    error('Could not read data from variable %s in file %s. Perhaps the file has been modified or moved?', obj.varName, obj.filename );
end
end