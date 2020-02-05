function[X, passVals] = read( file, scs, passVals )
% Returns data from a gridFile at the specified locations

% Either load grid data or used previously loaded data
if ~isempty( passVals{1} )
    grid = passVals{1};
else 
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
readLimit = NaN( nDim, 2 );
for d = 1:nDim
    gridIndex{d} = scs(1,d) : scs(3,d) : scs(1,d)+scs(3,d)*(scs(2,d)-1);
    readLimit(d,:) = [gridIndex{d}(1), gridIndex{d}(end)];
end

% Check each source to see if it contains any necessary data
for s = 1 : grid.nSource
    useSource = true;
    
    % Check each dimension for overlap
    for d = nDim:-1:1
        if all( readLimit(d,:) < grid.dimLimit(d,1,s) ) || all( readLimit(d,:) > grid.dimLimit(d,2,s) )
            useSource = false;
            break
        end
    end
    
    % If the source was useful, get the scs
    if useSource
        sSCS = [NaN(2, nDim); scs(3,:)];
        readIndex = cell( nDim, 1 );
        
        % Get the scs for each dimension
        for d = 1:nDim
            [~,loc] = ismember( gridIndex{d}, grid.dimLimit(d,1,s):grid.dimLimit(d,2,s) );
            readIndex{d} = find( loc~=0 );
            sourceIndex = loc( loc~=0 );
            sSCS(1,d) = sourceIndex(1);
            sSCS(2,d) = numel( sourceIndex );
        end
            
        % Build a dataGrid object to read from the source or retrieve
        % from a previous build.
        if isempty( passVals{s+1} )
            passVals{s+1} = grid.buildSource( s );
        end
        source = passVals{s+1};
            
        % Permute scs to match source order. Read. Permute back to grid order
        sSCS = gridFile.reorderSCS( sSCS, grid.dimOrder, source.dimOrder );
        [Xsource] = source.read( sSCS );
        X( readIndex{:} ) = gridFile.permuteSource( Xsource, source.dimOrder, grid.dimOrder );
    end
end

end