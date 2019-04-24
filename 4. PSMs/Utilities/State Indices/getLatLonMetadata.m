function[latlon] = getLatLonMetadata( ensMeta, vardex, varName )

% Get the lat lon and tripole dimensions
[~,~,~,lon,lat,~,~,~,tri] = getDimIDs;
dims = [lon;lat;tri];

% Track whether the dimensions have metadata that is not all NaN
hasmeta = false(3,1);

% Preallocate lat-lon metadata for each dimension
val = cell(3,1);

% Try converting each dimension to a matrix
for d = 1:3
    try
        val{d} = cell2mat( ensMeta.(dims(d))(vardex) );
        
        % If the dimension has non-nan elements, then it has metadata
        if any( ~isnan(val{d}(:)) )
            hasmeta(d) = true;
        end
      
    % If the matrix conversion fails, give a useful error
    catch
        error(['Could not retrieve %s metadata for variable %s.', newline, ...
            'It might be a spatial mean. (This function does not support spatial means.)'], ...
             dims(d), varName); 
    end
end

% Throw error if both/neither lat-lon and tripole have metadata
if all(hasmeta)
    error('Variable %s has both tripolar and lat-lon metadata.', varName);
elseif all( ~hasmeta )
    error('Variable %s has neither tripolar nor lat-lon metadata.', varName );
    
% Meanwhile, lat and lon should have the same value
elseif ~all( hasmeta(1:2) ) || ~all( ~hasmeta(1:2) )
    error('Only one of the the lat and lon dimensions of variable %s has metadata.', varName );
end


% If this is a tripolar grid
if hasmeta(3)
    
    % Check that the value is a 2D grid
    if ~ismatrix( val{3} )
        error('tripolar metadata must be a 2D matrix.');
        
    % With exactly two columns
    elseif size(val{3},2) ~= 2
        error('tripolar metadata must have 2 columns.');
    end
    
    latlon = val{3};
    
% Otherwise, use metadata from the lat and lon dimensions.
else
    if ~isvector( val{2} )
        error('latitude metadata must be a vector.');
    elseif ~isvector( val{1} )
        error('longitude metadata must be a vector.');
    end
    
    latlon = [val{2}, val{1}];
end

end