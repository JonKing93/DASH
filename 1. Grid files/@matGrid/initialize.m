function[path, file, var, order, msize, umsize, merge, unmerge] = ...
        initialize( file, var, dimOrder )
% Gets the values needed to initialize a matGrid in a .grid file.
    
% Check that the file exists, get the full path
if ~isstrflag( file )
    error('file must be a string scalar or character row vector.');
elseif ~exist( file, 'file' )
    error('The file %s does not exist. It may be misspelled or not on the active path.', file );
end
path = which( file );

% Check that the file is actually matfile V7.3
try
    m = matfile( file );
catch ME
    error('The file %s is not a valid .mat file.', file );
end

% Check that the variable name is allowed and exists
if ~isstrflag( var )
    error('var must be a string scalar or character row vector.');
end
names = string( who(m) );
[isvar] = ismember( var, names );
if ~isvar
    error('The file %s does not contain a %s variable.', file, var );
end
var = char(var);

% Process the dimensions. Record merging and sizes
[umsize, msize, order, merge, unmerge] = ...
    gridData.processSourceDims( dimOrder, size(m,var) );

% Check the data is numeric or logical
nDim = numel( umsize );
load1 = repmat( {1}, [nDim,1] );
val1 = m.(var)(load1{:});
if ~isnumeric( val1 ) && ~islogical( val1 )
    error('The variable %s is neither numeric nor logical.', var );
end

% Convert to comma delimited for file write
path = char(path);
file = char(file);
order = gridData.dims2char( order );

end
