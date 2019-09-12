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
    

    
    
    % Fill out the start and count
    start(d) = interval(1);
    count(d) = numel( interval );
        
    % Only keep points on the interval associated with sampling indices
    [~, keep{d}] = ismember( index, interval );
end

% Concatenate the loading arrays
loadNC = cat(1, start, count, stride );

end