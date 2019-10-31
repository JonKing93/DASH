function[X] = read( obj, start, count, stride, ~ )
%% Reads data from a source grid that is an external .mat file

% Check that the matfile still exists
if ~exist( obj.filepath, 'file' )
    error('The file %s no longer exists.', obj.filepath );
end
m = matfile( obj.filepath );

% Check that the variable still exists
vars = string( who(m) );
if ~ismember( obj.varName, vars )
    error('Variable %s no longer exists in file %s.', obj.varName, obj.filename );
end

% Check that the variable is the same size
siz = gridData.squeezeSize( size(m.(obj.varName)) );
if ~isequal( siz, obj.size )
    error('The variable %s in file %s has changed size since it was added to the .grid file.', obj.varName, obj.filename );
end

% Read the data
nDim = length(start);
loadIndex = cell(nDim,1);
for d = 1:nDim
    loadIndex{d} = start(d) : stride(d) : start(d)+stride(d)*(count(d)-1);
end
X = m.(obj.varName)( loadIndex{:} );

% Check that the data is still numeric or logical
if ~isnumeric(X) && ~islogical(X)
    error('The variable %s in file %s is neither numeric or logical. It may have been changed since it was added to the .grid file.', obj.varName, obj.filename );
end

end