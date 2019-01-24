function[H] = samplingMatrix( siteCoord, stateCoord, indexType )
%% Creates a sampling matrix or vector that maps site (lat-lon) coordinates
% to the nearest set of (lat-lon) coordinates on a grid or set of stations.
%
% H = samplingMatrix( siteCoord, stateCoord )
% Returns a logical sampling matrix.
%
% Hvec = samplingMatrix( siteCoord, stateCoord, 'linear' )
% Returns a vector of linear indices.
%
% Hvec = samplingMatrix( siteCoord, {gridLat, {gridLat, gridLon}, 'linear' )
% Returns a vector of linear indices after vectorizing a gridded set of
% lat-lon coordinates.
%
% Hsub = samplingMatrix( siteCoord, {gridLat, gridLon}, 'subscript' )
% Returns subscript indices for a gridded set of lat-lon coordinates.
%
% ----- Inputs -----
% 
% siteCoord: A two column matrix of site latitude (column 1) and longitude
%      (column 2) coordinates. (nSite x 2)
%
% stateCoord: A two column matrix of grid/station/domain coordinates. (nState x 2)
%
% gridLat: A 2D matrix of grid latitudes.
%
% gridLon: A 2D matrix of grid longitudes.
%
% ----- Outputs -----
%
% H: A logical sampling matrix. (nSite x nGrid)
%
% Hvec: A vector of linear sampling indices. (nSite x 1)
%
% Hrow: A vector of row sampling indices. (nSite x 1)
%
% Hcol: A two column matrix of 2D sampling subscript indices. (nSite x 2)

% Set a default for the index type
if nargin == 2
    indexType = 'logical';
end

% If 2D grid coordinates, convert to a vector
if iscell(stateCoord)
    lat = stateCoord{1}(:);
    lon = stateCoord{2}(:);
    
    gridSize = size( stateCoord{1} );
end

% Preallocate
nSite = size( siteCoord, 1);
Hvec = NaN( nSite, 1);

% For each site...
for s = 1:nSite
    
    % Get the distance between the site and grid coords
    dist = haversine( siteCoord(s,:), stateCoord );
    
    % Get the index of the minimum distance
    Hvec(s) = find( dist == min(dist), 1 );
end

% If returning a logical sampling matrix
if strcmpi( indexType, 'logical')
    
    % Preallocate
    nGrid = size( stateCoord, 1);
    H = false( nSite, nGrid);
    
    % For each site...
    for s = 1:nSite
        
        % Convert the sampling index to true
        H(s, Hvec(s)) = true;
    end

% Or output linear indices.
elseif strcmpi( indexType, 'linear')
    H = Hvec;
    
% Or get subscript indices
elseif strcmpi( indexType, 'subscript')
    [Hrow, Hcol] = ind2sub( gridSize, Hvec );
    H = [Hrow, Hcol];
end

end