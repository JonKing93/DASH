function[H] = getClosestLatLonIndex( obj, coord, varNames, varargin )
%% Gets the state indices closest to a particular lat-lon coordinate. from
% 
% H = obj.getClosestLatLonIndex( coord, varNames )
% Finds the closest state vector element to a coordinate for a set of
% variables.
%
% H = obj.getClosestLatLonIndex( ..., dim1, meta1, ... dimN, metaN )
% Finds the closest H for specific elements along specified dimensions.
% Searches each index associated with elements in the specified metadata.
%
% For Example:
%   >> H = obj.getClosestLatLonIndex( ..., 'lev', [100 200 300] )
%
%   would find three state elements. The closest on the level with metadata
%   equal to 100, the closest on level 200, and the closest on level 300.
%
% ----- Inputs -----
%
% coord: A set of lat-lon coordinates.
%
% varNames: A set of variable names. Must be a string column.
%
% dimN: The name of the Nth dimension with specific indices to search
%
% metaN: The metadata of indices along which to search for dimension N
%
% ----- Outputs -----
%
% H: State vector indices.

% Parse inputs. Dimension names can be changed, so do a general call
[dimID,~,~,lon,lat,~,~,~,tri] = getDimIDs;
nDim = numel(dimID);
norestrict = [lon;lat;tri];

metaValue = cell( nDim, 1 );
empty = repmat( {[]}, [nDim, 1] );

[metaValue{:}] = parseInputs( varargin, cellstr(dimID), empty, empty );
varNames = string(varNames);

% Get the number of indices to search in each dimension. Throw error if
% indices were provided for lat, lon, or tri
nEls = zeros( nDim, 1 );
for d = 1:nDim    
    if ismember(dimID(d), norestrict) && ~isempty(metaValue{d})
        error('Search values are not allowed for the %s dimension.', norestrict(d) );
    end    
    nEls(d) = size( metaValue{d}, 1 );
end

% Get the N-D subscript of each combination of dimensions. 
searchDim = find( nEls~=0 );
nDim = numel(searchDim);
nEls = nEls( searchDim );
subDex = subdim( (1:prod(nEls))', nEls );

% Preallocate the H indices
nComb = 1;
if ~isempty(subDex)
    nComb = size(subDex,1);
end
nVar = numel(varNames);
H = NaN( nComb*nVar, 1 );

% Get the v-index of each variable, extract metadata for each sequence
% element, and find the closest to the coordinate
for var = 1:numel(varNames)
    v = obj.varCheck( varNames(var) );
    latlon = obj.getLatLonMetadata( varNames(var) );
    dist = haversine( coord, latlon );
    site = find( dist == min(dist), 1 );
    
    % Initialize the dimension search
    searchIndex = cell( nDim, 1 );
    subSearch = subDex;
    nModulus = NaN( 1, nDim );
    
    % For each dimension with search values, get the indices where the
    % metadata is located. Subscript to N-D
    for dim = 1:nDim
        d = searchDim(dim);
        stateMeta = obj.stateMeta.(obj.varName(v)).(dimID(d));
        
        if size(metaValue{d}, 2) ~= size(stateMeta,2)
            error('The metadata search values do not have the same number of rows as the ensemble metadata.');
        end
        
        [~, searchIndex{dim}] = ismember( metaValue{d}, obj.stateMeta.(obj.varName(v)).(dimID(d)), 'rows' );
        if any( searchIndex{dim} == 0 )
            error('Variable %s does not have matching metadata along the %s dimension.', varNames(var), dimID(d) );
        end
        subSearch(:,dim) = searchIndex{dim}(subDex(:,dim)); 
        nModulus(dim) = prod( obj.varSize(v,1:d-1) );
    end
    
    % Modulate the closest site (within a single sequence element), over
    % the N-D set of search dimensions
    nAdd = 0;
    if ~isempty( subSearch )
        nAdd = sum( (subSearch-1).*nModulus, 2 );
    end
    H((var-1).*nComb+(1:nComb)) = (obj.varLimit(v,1) - 1) + nAdd + site;
    
end

end