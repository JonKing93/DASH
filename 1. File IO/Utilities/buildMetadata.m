function[meta] = buildMetadata( gridDims, gridSize, specs, varargin)
%% This converts user metadata to the structure used by dash. Metadata in
% unspecified dimensions is set to NaN. Checks that metadata size matches
% the size of gridded data. Dimensional metadata must have one row for each 
% index in the dimension. Metadata must be specified for all non-singleton
% dimensions.
%
% meta = buildMetadata( gridDims, gridSize, specs, dim1, meta1, dim2, meta2, ..., dimN, metaN )
% Converts user specified metadata to the metadata structure used by dash.
%
% ----- Inputs -----
%
% gridDims: A cell of dimension IDs indicating the order of dimensions in
%       the gridded data. A vector of strings. (nDim x 1)
%
% gridSize: The size of the dimensions in the gridded dataset. (nDim x 1)
%
% specs: A struct that contains non-dimensional metadata for the variable.
%   This could include values like the variable name and units. Each field
%   should be one variable attribute. Attributes must be valid NetCDF4 data
%   types.
%
% dimN: A dimension ID for the Nth input dimension.
%
% valN: The metadata for the Nth input dimension. May be N-dimensional, but
%       the number of rows must match the length of the corresponding
%       dimension in the gridded data.
%       Must be a valid NetCDF4 data type. (See listNcTypes.m for valid types.)
%
% ----- Outputs -----
%
% meta: The metadata structure used by dash to build a .grid file.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check the inputs. Ensure names are strings.
[gridDims, metaDim] = setup( gridSize, gridDims, specs, varargin );

% Get the known dimension IDs
[dimID, specName] = getDimIDs;
nDim = numel(dimID);

% Initialize the metadata structure with the variable attributes
meta.(specName) = specs;

% For each dimension
for d = 1:nDim
    
    % Check if the dimension is known to the user
    [isGridDim, g] = ismember( dimID(d), gridDims);
    
    % Get the size of the dimension. If the dimension is user-known, get
    % the specified size. Otherwise, set this as a singleton dimension.
    dimSize = 1;
    if isGridDim
        dimSize = gridSize(g);
    end
    
    % Check if this is a dimension with specified metadata
    [ismeta, v] = ismember(d, metaDim);
    
    % If this is a metadata dimension
    if ismeta
        
        % Get the metadata values
        value = varargin{v*2};
        
        % Check that the metadata is an allowed type
        if ~isnctype( value )
            error('The %s metadata is not an allowed NetCDF type. Please see listNcTypes.m for the allowed data types.', dimID(d));
        elseif ~ismatrix( value )
            error('The %s metadata is not a matrix.', dimID(d));
        end 
            
        % Check that the number of rows is correct
        value = checkMetadataRows( value, dimSize, dimID(d) );
        
        % Check that there are no duplicate rows
        if size(value,1) ~= size( unique(value, 'rows'), 1 )
            error('The %s metadata contains duplicate values.', dimID(d));
        end
             
    % Otherwise, there is no specified metadata for this dimension.
    else
        
        % Ensure that it is a singleton dimension.
        if dimSize > 1
            error('No metadata was specified for the %s dimension.', dimID(d));
        end
            
        % Use NaN as the metadata value for singleton dimensions with
        % unspecified metadata
        value = NaN;
    end

    % Add the dimension and associated metadata to the output structure
    meta.(dimID(d)) = value;
end

end

%% Error checking and setup helper function
function[gridDims, metaDim] = setup( gridSize, gridDims, specs, meta )

% varSpecs must be scalar
if ~isstruct(specs) || ~isscalar(specs)
    error('The variable ''specs'' must be a scalar structure (struct).');
end

% Check the dimension IDs, convert to string
gridDims = checkGridDims(gridDims);

% Check that gridSize is a vector of positive integers
if ~isvector(gridSize) || any(gridSize < 1) || any( mod(gridSize,1)~=0 )
    error('gridSize must be a vector of positive integers.');
end

% Check that gridDims is a vector with the same length as gridSize
if ~isvector(gridDims) || length(gridDims)~=length(gridSize)
    error('gridSize must be a vector of dimension IDs that matches the length of ''gridDims''.');
end

% Check that the number of metadata elements is even
nDim = numel(meta)/2;
if mod(nDim,1)~=0
    error('There must be exactly one set of metadata values for each metadata dimension.');
end

% Initialize an array to record the index of each metadata dimension in the
% total set of dimension IDs
metaDim = NaN(nDim,1);

% Check that the odd elements of varargin are non-duplicate dimIDs
dimID = getDimIDs;
for v = 1:2:numel(meta)
    
    % Check whether the dimension is recognized
    [isdim, d] = ismember( meta{v}, dimID );
    
    % If not a dimension ID, throw an error
    if ~isdim
        error('Input %0.f is not a recognized dimension ID.', v+3);
        
    % If allowed, then get the index in the set of all recognized
    % dimensions
    else
        
        % Check for duplicate
        if ismember(d, metaDim)
            error('Metadata for dimension %s is provided multiple times.', meta{v} );
        
        % Record index if not duplicate
        else
            metaDim((v+1)/2) = d;
        end
    end
end

% Check that each field of specs is a NetCDF4 type
specNames = string( fieldnames( specs ) );
for s = 1:numel(specNames)
    if ~isnctype( specs.(specNames(s)) )
        error('The "%s" attribute in the "specs" structure contains data that is not a valid NetCDF4 type.', specNames(s) );
    end
end

end