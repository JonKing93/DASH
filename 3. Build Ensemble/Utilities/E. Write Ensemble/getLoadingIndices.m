function[loadNC, keep] = getLoadingIndices( var )

% Create an array to hold the start count and stride for loading from the .grid file
nDim = numel( var.dimID );
start = NaN( 1, nDim );
count = NaN( 1, nDim );
stride = ones( 1, nDim );

% Initialize a cell of indices to record which loaded values should be kept
% (Can only load with uniform spacing, so need to load an entire interval
% for non-uniform)
keep = repmat( {':'}, [1,nDim] );

% For each dimension
for d = 1:nDim
    
    % If a state dimension, the smallest set of continguous loaded data is
    % a set of state indices
    if var.isState(d)
        index = var.indices{d};
        
    % For ensembles, a set of mean indices is the smallest set of
    % contiguous loaded data
    else
        index = var.meanDex{d};
    end
    
    % Sort the indices to test for uniform spacing
    interval = sort( index );
    
    % If unevenly spaced, load every index on the interval
    if numel(index)>1 && numel(unique(diff(interval)))>1
        interval = interval(1):interval(end);
        
    % Correct stride if evenly spaced
    elseif numel(index)>1
        stride(d) = unique( diff(index) );
    end
    
    % Fill out the start and count
    start(d) = interval(1);
    count(d) = numel( interval );
        
    % Only keep points on the interval associated with sampling indices
    [~, keep{d}] = ismember( index, interval );
end

% Concatenate the loading arrays
loadNC = cat(1, start, count, stride );

end