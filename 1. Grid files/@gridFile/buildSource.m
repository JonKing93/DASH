function[source] = buildSource( obj, s )
% Returns the dataGrid object for a particular data source in a .grid file.

% Extract the info for the source
m = load( obj.filepath, '-mat', 'sourcePath', 'sourceFile', 'sourceVar', ...
          'sourceDims','sourceOrder','sourceSize','unmergedSize', 'merge', 'unmerge', 'counter', 'type' );
counter = m.counter(s,:);
type = m.type(s,:);
path = string( m.sourcePath( s, 1:counter(1) ) );
file = string( m.sourceFile( s, 1:counter(2) ) );
var = string( m.sourceVar( s, 1:counter(3) ) );
dims = gridData.char2dims( m.sourceDims(s, 1:counter(4)) );
order = gridData.char2dims( m.sourceOrder(s, 1:counter(5)) );
msize = m.sourceSize( s, 1:counter(6) );
umsize = m.unmergedSize( s, 1:counter(7) );
merge = m.merge( s, 1:counter(8) );
unmerge = m.unmerge( s, 1:counter(9) );

% Build an ncGrid
if strcmp( type, 'nc   ')
    source = ncGrid( path, file, var, dims, order, msize, umsize, merge, unmerge );
    
% matGrid
elseif strcmp(type, 'mat  ')
    source = matGrid( path, file, var, order, msize, umsize, merge, unmerge );
end

end