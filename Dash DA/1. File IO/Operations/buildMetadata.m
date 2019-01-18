function[meta] = buildMetadata( gridData, gridDims, varName, varargin)
%% This converts user metadata to the structure used by dash. Metadata in
% unspecified dimensions is set to NaN. Checks that metadata size matches
% the size of gridded data.
%
% meta = buildMetadata( gridData, gridDims, dim1, val1, dim2, val2, ... )
% Converts user metadata to a metadata structure used by dash.
%
% ----- Inputs -----
%
% gridData: A gridded dataset
%
% gridDims: A cell of dimension IDs indicating the order of dimensions in
%       the gridded data.
%
% varName: A string with the name of the data variable.
%
% dimN: A dimension ID for the Nth input dimension.
%
% valN: The metadata for the Nth input dimension. Must be a vector whose
%       length matches the size of the corresponding dimension in the
%       gridded data.
%
% ----- Outputs -----
%
% meta: The metadata structure used by dash.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019
%

% Error check the variable name
if ~(isstring(varName) && isscalar(varName)) && ~(ischar(varName) && isvector(varName))
    error('varName must be a char vector.');
end

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
    
    % Convert to column cell
    if isrow(value)
        value = value';
    end
    if ~iscell(value)
        value = num2cell(value);
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
meta = struct('var', varName );

% Fill in the cell metadata
if numel(metaCell)>2
    for m = 3:2:numel(metaCell)
        meta.(metaCell{m}) = metaCell{m+1};
    end
end

end