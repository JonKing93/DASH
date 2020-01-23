function[X, passVals] = read( file, scs, passVals )
% Returns data from a gridFile at the specified locations

% Either load grid data or used previously loaded data
if ~isempty( passVals{1} )
    grid = passVals{1};
else 
% !!! DELETE!!! %     grid = load(file, '-mat', 'source','dimLimit','dimOrder','gridSize');
    grid = gridFile( file );
    passVals{1} = grid;
end

% Check scs
if ~isnumeric(scs) || ~isreal(scs) || any(scs(:)<1) || any(mod(scs(:),1)~=0)
    error('scs must be a matrix of positive integers.');
elseif ~isequal( [3, numel(grid.dimOrder)], size(scs) )
    error('scs must be (3 x %.f)', numel(grid.dimOrder) );
elseif any( scs(1,:) + scs(3,:).*(scs(2,:)-1) > grid.gridSize )
    error('The read indices for dimension %s are longer than the dimension.', m.dimOrder(find(scs(1,:) + scs(3,:).*(scs(2,:)-1) > grid.gridSize, 1)) );
end

% Preallocate the read grid
X = NaN( scs(2,:) );

% Get the grid Indices to be loaded for each dimension.
nDim = numel( grid.dimOrder );
gridIndex = cell( nDim,1 );
for d = 1:nDim
    gridIndex{d} = scs(1,d) : scs(3,d) : scs(1,d)+scs(3,d)*(scs(2,d)-1);
end

% Preallocate scs for each source grid and indices in overall read grid
for s = 1 : grid.nSource
    useSource = true;
    sSCS = [NaN(2, nDim); scs(3,:)];
    readIndex = cell( nDim, 1 );
    
    % Check if it contains any data to be read. If so, get the start and
    % count within the source grid. Also note which data it is reading
    for d = 1:nDim
        [~, loc] = ismember( gridIndex{d}, grid.dimLimit(d,1,s):grid.dimLimit(d,2,s) );
        if all(loc==0)
            useSource = false;
            break;
        end
        
        readIndex{d} = find( loc~=0 );
        sourceIndex = loc( loc~=0 );
        sSCS(1,d) = sourceIndex(1);
        sSCS(2,d) = numel( sourceIndex );
    end
    
    % Read data from the source. Create a dataGrid object to coordinate the
    % read. Permute scs/output to match source/grid dimension order.
    if useSource
        source = gridFile.buildSource( s );
        sSCS = gridFile.reorderSCS( sSCS, grid.dimOrder, source.dimOrder );
        [Xsource, passVals{s+1}] = source.read( sSCS, file, passVals{s+1} );
        X( readIndex{:} ) = gridFile.permuteSource( Xsource, source.dimOrder, grid.dimOrder );
    end
    
end

end