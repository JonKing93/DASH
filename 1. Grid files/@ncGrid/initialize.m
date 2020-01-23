function[path, file, var, dims, order, msize, umsize, merge, unmerge] = ...
                              initialize( file, var, dimOrder )
% Gets the initial fields required to write a ncgrid to .grid file

% Check that the file exists, get the full path
if ~isstrflag( file )
    error('file must be a string scalar or character row vector.');
elseif ~exist( file, 'file' )
    error('The file %s does not exist. It may be misspelled or not on the active path.', file );
end
path = which( file );

% Check that the file is actually a netcdf
try
    info = ncinfo( path );
catch ME
    error('The file %s is not a valid NetCDF file.', file );
end

% Check that the variable name is allowed and exists
if ~isstrflag( var )
    error('var must be a string scalar or character row vector.');
end
ncVars = cell( numel(info.Variables), 1 );
[ncVars{:}] = deal( info.Variables.Name );        
ncVars = string( ncVars );
[isvar, v] = ismember( var, ncVars );
if ~isvar
    error('The file %s does not contain a %s variable.', file, var );
end

% Ensure the data field is numeric or logical
if ~ismember( info.Variables(v).Datatype, [gridData.numericTypes;"logical"] )
    error('The %s variable is neither numeric nor logical.', var );
end

% Process the dimensions. Find merged / unmerged size.
[umsize, msize, order, merge, unmerge] = ...
    gridData.processSourceDims( dimOrder, info.Variables(v).Size );

% Also record the dimensions saved in the NetCDF file.
ncDim = cell( 1, numel(info.Variables(v).Dimensions) );
[ncDim{:}] = deal( info.Variables(v).Dimensions.Name );
dims = string( ncDim );

% Convert to comma delimited chars for the .grid file
path = char(path);
file = char(file);
var = char(var);
dims = gridData.dims2char( dims );
order = gridData.dims2char( order );

end