function[] = checkOverlap( dimLimit, gridLimit )
% Checks if a data source will overlap existing sources

% Track whether each dimension overlaps in each variable
[nDim, ~, nSource] = size(gridLimit);
for v = 1:nSource
    overlap = false(nDim,1);
    
    % No overlap occurs if both limits are higher/lower than the grid limit
    for d = 1:nDim
        bothLower = all( dimLimit(d,:) < gridLimit(d,1,v) );
        bothHigher = all( dimLimit(d,:) > gridLimit(d,2,v) );
        overlap(d) = ~( bothLower | bothHigher );
    end
    
    % If all dimensions overlap, then it overlaps the data source
    if all( overlap )
        error('The new data source overlaps data already in the .grid file.');
    end
end

end