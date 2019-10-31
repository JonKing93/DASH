function[] = checkOverlap( dimLimit, gridLimit )
% Checks if a data source will overlap existing sources

% Track whether each dimension overlaps in each variable
[nDim, ~, nVar] = size(gridLimit);
overlap = false( nDim, nVar );

for d = 1:nDim
    sourceIndex =- dimLimit(d,1):dimLimit(d,2);
    for v = 1:nVar
        overlap(d,v) = any( ismember( sourceIndex, gridLimit(d,1,v):gridLimit(d,2,v) ) );
    end
end

% If all the dimensions overlap for any variable, then it overlaps the new
% data source
if ~isempty(overlap) && any( all(overlap) )
    error('The new data source overlaps data already in the .grid file.');
end

end
    
    
    