function[X] = read( obj, start, count, stride, ~ )
% Reads data from a NetCDF file in a gridFile.

% Check the netcdf still exists and is still a netcdf
if ~exist( obj.filepath, 'file' )
    error('The file %s no longer exists.', obj.filepath );
end
try
    info = ncinfo( obj.filepath );
catch ME
    error('The file %s is not a valid NetCDF file. It may have been altered after it was added to the .grid file.', obj.filename );
end

% Check the variable still exists, is numeric, and has the same size
ncNames = cell( numel(info.Variables), 1 );
[ncNames{:}] = deal( info.Variables.Name );        
ncNames = string( ncNames );
[isvar, v] = ismember( obj.varName, ncNames );
if ~isvar
    error('The file %s does not contain a %s variable.', obj.filename, obj.varName );
elseif ~ismember( info.Variables(v).Datatype, [gridData.numericTypes;"logical"] )
    error('The %s variable in file %s is neither numeric nor logical.', obj.varName, obj.filename );
elseif ~isequal(  gridData.squeezeSize( info.Variables(v).Size ), obj.size )
    error('The %s variable in file %s has changed size since it was added to the .grid file.', obj.varName, obj.filename );
end

% Adjust the size of start, count, stride for the number of netcdf dimensions
nNcdim = numel( info.Variables(v).Dimensions );
nGdim = length(start);
if nNcdim < nGdim
    start = start(1:nNcdim);
    count = count(1:nNcdim);
    stride = stride(1:nNcdim); 
elseif nNcdim > nGdim
    nExtra = nNcdim - nGdim;
    start(end + (1:nExtra)) = 1;
    count(end + (1:nExtra)) = 1;
    stride(end + (1:nExtra)) = 1;
end

% Read from the netcdf file
X = ncread( obj.filepath, obj.varName, start, count, stride );

end