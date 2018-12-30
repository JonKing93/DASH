function[meta] = buildMetadata( gridData, gridDims, varName, varargin)
%
%
% meta = buildMetadata( gridData, gridDims, varName, ...)

% Get the known dimension IDs
knownID = getKnownIDs;
nDim = numel(knownID);

% Permute the knownIDs to match the data order
permDex = getPermutation( knownID, gridDims, knownID );
dimID = knownID(permDex);

% Get the size of the gridded data
sData = fullSize( gridData, nDim );

% Create a cell to hold the metadata fields
metaCell = cell( nDim*2, 1 );

% Add the field names to the cell
metaCell(1:2:end) = dimID;

% For each input name-value pair...
for v = 1:2:numel(varargin)
    
    % Find the index of the matching field name
    [~, index] = ismember( varargin{v}, dimID );
    
    % Error check the input value
    value = varargin{v+1};
    if ~isvector( value )
        error('Metadata must be a vector');
    elseif numel(value) ~= sData(index)
        error('The size of the %s metadata does not match the size of the dimension in the gridded data.', dimID{index} );
    end
    
    % Add the value to the cell
    metaCell{index*2} = value;
end

% Fill any unspecified metadata with NaN
for m = 2:2:numel(metaCell)
    if isempty( metaCell{m} )
        metaCell{m} = NaN( sData(m/2), 1 );
    end
end

% Create the metadata structure
meta = struct('var', varName, metaCell{:} );

end