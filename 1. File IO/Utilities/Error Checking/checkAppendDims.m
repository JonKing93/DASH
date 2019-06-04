function[append] = checkAppendDims( appendDims )
%% Error checks append dims, converts to string, and organizes in the same
% order as dimID

% Error check and convert to string.
appendDims = checkDimList( appendDims, 'appendDims' );

% Get the dimID order
dimID = getDimIDs;

% Get the boolean array of append dimensions in the order of dimID
append = ismember( dimID, appendDims );

end