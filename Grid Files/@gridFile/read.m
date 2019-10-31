function[X] = read( file, start, count, stride )
% Returns data from a .gridFile at the specified locations

% Check the file
gridFile.fileCheck( file );
m = matfile( file );
source = m.source;
dimLimit = m.dimLimit;
nDim = numel( m.dimOrder );

% Check that start, count, and stride are vectors of positive integers,
% each with one element per grid dimension.
if ~isnumeric(start) || ~isreal(start) || ~isrow(start) || any(start<1) || any(mod(start,1)~=0)
    error('start must be a row vector of positive integers');
elseif ~isnumeric(count) || ~isreal(count) || ~isrow(count) || any(count<1) || any(mod(count,1)~=0)
    error('count must be a row vector of positive integers.');
elseif ~isnumeric(stride) || ~isreal(stride) || ~isrow(stride) || any(stride<1) || any(mod(stride,1)~=0)
    error('stride must be a row vector of positice integers.');
elseif length(start)~=nDim || length(count)~=nDim || length(stride)~=nDim
    error('start, count, and stride must all have %.f elements.', nDim );
elseif any( start + stride.*(count-1) > m.gridSize )
    error('The read indices for dimension %s are longer than the dimension.', m.dimOrder(find(start + stride.*(count-1) > m.gridSize,1)) );
end

% Preallocate the read grid
X = NaN( count );
warning('Need to build a type check.');

% Get the grid Indices to be loaded for each dimension.
gridIndex = cell( nDim,1 );
for d = 1:nDim
    gridIndex{d} = start(d) : stride(d) : start(d)+stride(d)*(count(d)-1);
end

% For each source grid
for s = 1:numel(source)
    useSource = true;
    sStart = NaN( nDim, 1 );
    sCount = NaN( nDim, 1 );
    readIndex = cell( nDim, 1 );
    
    % Check if it contains any data to be read. If so, get the start and
    % count within the source grid. Also note which data it is reading
    for d = 1:nDim
        [~, loc] = ismember( gridIndex{d}, dimLimit(d,1,s):dimLimit(d,2,s) );
        if all(loc==0)
            useSource = false;
            break;
        end
        
        readIndex{d} = find( loc~=0 );
        sourceIndex = loc( loc~=0 );
        sStart(d) = sourceIndex(1);
        sCount(d) = numel( sourceIndex );
    end
    
    % Read the data from the source grid. Permute to match the grid file
    % dimensional order
    if useSource
        Xsource = source{s}.read( sStart, sCount, stride );
        X( readIndex{:} ) = gridFile.permuteSource( Xsource, source.dimOrder, m.dimOrder );
    end
    
end