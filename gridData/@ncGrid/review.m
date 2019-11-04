% Check the netcdf still exists and is still a netcdf
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