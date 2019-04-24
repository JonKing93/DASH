function[H] = getClosestLatLonIndex( coord, ensMeta, varNames, varargin )

% Start by getting the names of all the dimension IDs
dimID = getDimIDs;
nDim = numel(dimID);

% Preallocate args for call to parseInputs
restrict = cell( nDim, 1 );
empty = repmat( {[]}, [nDim, 1] );

% Get the restriction values for each dimension
restrict{:} = parseInputs( varargin, dimID, empty, empty );

% Preallocate which dimensions have restriction metadata, and the number of
% metadata elements for the dimensions.
hasres = false( nDim, 1 );
nEls = NaN( nDim, 1 );

% Get the dimensions with restrictions and the number of restrictions
for d = 1:nDim
    if ~isempty( restrict{d} )
        hasres(d) = true;
        nEls(d) = size( restrict{d}, 1 );
        
        % Also check that each dimension is in the metadata
        dimCheck(ensMeta, dimID(d) );
    end
end

% Limit everything to dimensions with restriction metadata
dimID = dimID( hasres );
restrict = restrict( hasres );
nEls = nEls( hasres );
nDim = numel( dimID );

% Get the total number of combinations of restriction metadata. This is
% the total number of state indices per variable.
nDex = prod( nEls );

% Get N-D subscript indices for each combination of metadata
subDex = subdim( nEls, (1:nDex)' );

% Preallocate a cell to hold dimension values for each state index
dimVal = cell( nDim, 1 );

% Get the dimension values for each state index
for d = 1:nDim
    dimVal{d} = restrict{d}(subDex(:,d), :);
end

% Check that the ensemble metadat has lat, lon and tripole dimensions
[~,~,~,lon,lat,~,~,~,tri] = getDimIDs;
varCheck(ensMeta, lon);
varCheck(ensMeta, lat);
varCheck(ensMeta, tri);

% Preallocate the state indices
nVar = numel( varNames );
H = NaN( nVar*nDex, 1 );

% For each variable
for v = 1:nVar
    
    % Get the indices of the variable in the state vector
    varDex = varCheck( ensMeta, varNames(v) );
    
    % Get the lat-lon metadata associated with this variable
    latlon = getLatLonMetadata( ensMeta, varDex, varNames(v) );
    
    % For each state index in the variable
    for s = 1:nDex
        
        % Initialize the restricted indices
        stateDex = varDex;
        
        % Restrict in the appropriate dimensions
        for d = 1:nDim
                        
            % Find the indices of restriction values for the dimension
            resDex = findincell( dimVal{d}(s), ensMeta.(dimID(d))(stateDex) );
            
            % Restrict the state indices
            stateDex = stateDex( resDex );
        end
        
        % Determine the closest lat-lon value
        site = samplingMatrix( coord, latlon(stateDex,:), 'linear' );
        
        % Get the location within the entire state vector
        H( (v-1*nDex) + s ) = stateDex( site );
    end
end

end