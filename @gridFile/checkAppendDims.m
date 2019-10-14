function[append] = checkAppendDims( appendDims )
%% Error checks append dims, converts to string, and organizes in the same
% order as dimID

% Default is no append
append = false( size(getDimIDs) );

% Error check and convert to string.
if ~isempty( appendDims )
    appendDims = gridFile.checkDimList( appendDims, 'appendDims' );
    
    % Get booelan array of append dimensions
    append = ismember( getDimIDs, appendDims );
end

end