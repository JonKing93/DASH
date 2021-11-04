function[] = add(obj, type, source, varargin)
%% gridfile.add  Catalogue a data source in a .grid file
% ----------
%   obj.add('nc', file, variable, dimensions, metadata)
%   obj.add('nc', opendapURL, variable, dimensions, metadata)
%   Adds a NetCDF variable to the .grid file catalogue. The NetCDF can be
%   accessed either via a local file, or opendap URL.
%
%   obj.add('mat', file, variable, dimensions, metadata)
%   Adds a variable saved in a MAT-file to the .grid file catalogue.
%
%   obj.add('text', file, dimensions, metadata)
%   obj.add(..., opts)
%   obj.add(..., Name, Value)
%   Adds data stored in a delimited text file to the .grid file catalogue.
% ----------
%   Inputs:
%       file (string scalar): The name of a data source file. Name may
%           either be an absolute file path, or the name of a file on the
%           active path.
%       opendapURL (string scalar): An OPENDAP url to a data source file       
%       variable (string scalar): The name of a variable in a NetCDF or
%           MAT-file. Only this variable is catalogued in the gridfile.
%       dimensions (string vector): The order of dimensions for data in the
%           data source. Dimensions with repeated names are merged when
%           loading data from the gridfile.
%       metadata (scalar gridMetadata object): Dimensional metadata for the
%           data source. The number of rows must match the length the size
%           of the dimension in the data source. Must include metadata for
%           all non-singleton dimensions in both the gridfile and data
%           source. Metadata values for gridfile dimensions must exactly
%           match a sequence of gridfile metadata for the dimension.
%       opts (ImportOptions object): Additional options for importing data
%           from delimited text files using the builtin "readmatrix" function.
%       Name,Value: Additional import options for reading data from a
%           delimited text file using the builtin "readmatrix" functions.
%           (See the readmatrix reference page for supported pairs.)
%
% <a href="matlab:dash.doc('gridfile.add')">Documentation Page</a>

% Setup
obj.update;
header = "DASH:gridfile:add";

% Just write .mat version for now
assert(strcmp(type, 'mat'));

% Extract inputs
assert(numel(varargin)==3)
[variable, dimensions, metadata] = varargin{:};

% Build the data source, this will error check the file and variable. Also
% error check the metadata
source = dash.dataSource.mat(source, variable);
dash.assert.scalarType(metadata, 'gridMetadata', 'metadata', header);

% Check dimensions are recognized
valid = gridMetadata.dimensions;
dimensions = dash.assert.strlist(dimensions);
dash.assert.strsInList(dimensions, valid, 'dimensions', 'recognized dimension', header);

% Get lists of dimensions and sizes
listedDims = dimensions;                 % dimensions listed by user in function call
sourceDims = listedDims(source.size>1);  % non-singleton listed dimensions
gridDims = obj.dims(obj.size>1);         % non-singleton gridfile dimensions
metaDims = metadata.defined;             % metadata dimensions

nListed = numel(listedDims);
nGridDims = numel(gridDims);
nMetaDims = numel(metaDims);

% Parameters for error checking
nNontrailing = find(source.size>1, 1, 'last');
[gridInMeta, gm] = ismember(gridDims, metaDims);
[sourceInMeta, sm] = ismember(sourceDims, metaDims);
[sourceInGrid, sg] = ismember(sourceDims, gridDims);

% Require:
% 1. Non-trailing source dimensions to have a name
% 2. Non-singleton grid dimensions to be in the metadata
% 3. Non-singleton source dimensions to be in the metadata
% 4. Non-singleton source dimensions to be in the gridfile
if nListed < nNontrailing
    unnamedDimensionError(nListed, nNontrailing, source.source, header); 
elseif ~all(gridInMeta)
    missingGridMetadataError(gridDims, gm, source.source, obj.name, header);
elseif ~all(sourceInMeta)
    missingSourceMetadataError(sourceDims, sm, source.source, header);
elseif ~all(sourceInGrid)
    undefinedSourceDimensionError(sourceDims, sg, source.source, obj.name, header);
end

% Pad source size with trailing 1s if it is shorter than listed dimensions.
% Remove excess trailing 1s
sourceSize = source.size;
nSize = numel(sourceSize);
if nSize < nListed
    sourceSize = [sourceSize, ones(1, nListed-nSize)];
elseif nSize > nListed
    sourceSize = sourceSize(1:nListed);
end

% Get merged dimensions, sizes, and merge map
mergedDims = unique(listedDims, 'stable');
nMerged = numel(mergedDims);
mergedSize = NaN(1, nMerged);
mergeMap = NaN(1, nListed);
for d = 1:nMerged
    originalDimLocation = strcmp(mergedDims(d), listedDims);
    mergeMap(originalDimLocation) = d;
    mergedSize(d) = prod( sourceSize(originalDimLocation) );
end

% Get values and sizes of dimensional metadata. Initialize dimensional limits
dimLimit = ones(nGridDims, 2);
for d = 1:nMetaDims
    dim = metaDims(d);
    metaValues = metadata.(dim);
    nRows = size(metaValues, 1);
    
    % If a metadata dimension is missing from the source, the metadata must
    % have a single row (implies the dimension is singleton in the source).
    % Otherwise, require the number of rows to match the length of the
    % merged dimension.
    [insource, m] = ismember(dim, mergedDims);
    if ~insource && nRows~=1
        missingMetadataDimensionError(dim, source.source, header);
    elseif insource && nRows~=mergedSize(m)
        wrongMetadataRowsError(dim, nRows, mergedSize(m), source.source, header);
    end
    
    % If the metadata dimension is in the gridfile, it must exactly match a
    % sequence of gridfile metadata
    [ingrid, g] = ismember(dim, gridDims);
    if ingrid
        [inGridMetadata, order] = ismember(metaValues, obj.meta.(dim), 'rows');
        if ~all(inGridMetadata)
            differentMetadataError(dim, order, source.source, obj.name, header);
        elseif ~issorted(order, 'strictascend')
            metadataOrderError(dim, source.source, obj.name, header);
        elseif nRows>1 && ~isequal(unique(diff(order)), 1)
            skippedMetadataError(dim, source.source, obj.name, header);
        end
        
        % Record dimension limits
        dimLimit(g,:) = [min(order), max(order)];
    end
end

% Ensure the data source does not overlap another data source
lower = all(dimLimit<obj.dimLimit(:,1,:), 2);
higher = all(dimLimit>obj.dimLimit(:,2,:), 2);
overlap = all(~(lower|higher), 1);
if any(overlap)
    overlappingDataSourceError(source.source, overlap, obj, header);
end

% Add the new source to the gridfile
obj.sources = obj.sources.add(source, listedDims, sourceSize, mergedDims,...
    mergedSize, obj.fill, obj.range, obj.transform_, obj.transform_params);
obj.dimLimit = cat(3, obj.dimLimit, dimLimit);

% Save to file
obj.save;

end


% Long error messages
function[] = unnamedDimensionError(nListed, nNontrailing, sourceName, header)
id = sprintf('%s:unnamedDimension', header);
error(id, ['The number of listed dimensions (%.f) is smaller than the number ',...
    'of non-trailing dimensions (%.f) in data source "%s".'], ...
    nListed, nNontrailing, sourceName);
end
function[] = missingGridMetadataError(gridDims, loc, sourceName, gridName, header)
id = sprintf('%s:missingGridMetadata', header);
missing = find(loc==0, 1);
missing = gridDims(missing);
error(id, ['The data source metadata is missing the "%s" dimension, which ',...
    'is required by this gridfile.\nData source: %s\ngridfile: %s'],...
    missing, sourceName, gridName);
end  
function[] = missingSourceMetadataError(sourceDims, loc, sourceName, header)
id = sprintf('%s:missingSourceMetadata', header);
missing = find(loc==0, 1);
missing = sourceDims(missing);

error(id, 'The "%s" dimension is not in the metadata for data source "%s".',...
    missing, sourceName);
end
function[] = undefinedSourceDimensionError(sourceDims, loc, sourceName, gridName, header)
id = sprintf('%s:undefinedSourceDimension', header);
undefined = find(loc==0, 1);
undefined = sourceDims(undefined);

error(id, ['The "%s" data source dimension is not in the gridfile. Consider ',...
    'adding "%s" metadata to the gridfile. (See gridfile.expand)\n',...
    'Data source: %s\ngridfile: %s'], undefined, undefined, sourceName, gridName);
end
function[] = missingMetadataDimensionError(dim, sourceName, header)
id = sprintf('%s:missingMetadataDimension', header);
error(id, ['The "%s" dimension in the metadata is not included ',...
    'in the dimensions list for data source "%s".'], dim, sourceName);
end
function[] = wrongMetadataRowsError(dim, nRows, dimLength, sourceName, header)
id = sprintf('%s:wrongNumberOfMetadataRows', header);
error(id, ['The number of metadata rows for the "%s" dimension (%.f) ',...
    'does not match the length of the dimension (%.f) in data source "%s".'],...
    dim, nRows, dimLength, sourceName);
end
function[] = differentMetadataError(dim, loc, sourceName, gridName, header)
id = sprintf('%s:differentMetadata', header);
row = find(loc==0, 1);

error(id, ['Row %.f of the "%s" metadata for the data source ',...
    'does not match any rows of "%s" metadata in the gridfile.\n',...
    'Data source: %s\ngridfile: %s'], row, dim, dim, sourceName, gridName);
end
function[] = metadataOrderError(dim, sourceName, gridName, header)
id = sprintf('%s:invalidMetadataOrder', header);
error(id, ['The "%s" metadata for the data source is in a different ',...
    'order than the "%s" metadata for the gridfile.\n ',...
    'Data source: %s\ngridfile: %s'], dim, dim, sourceName, gridName);
end
function[] = skippedMetadataError(dim, sourceName, gridName, header)
id = sprintf('%s:skippedMetadata', header);
error(id, ['The "%s" metadata for the data source skips elements ',...
    'of the "%s" metadata in the gridfile.\nData source: %s\n',...
    'gridfile: %s'], dim, dim, sourceName, gridName);
end
function[] = overlappingDataSourceError(sourceName, overlap, obj, header)
id = sprintf('%s:overlappingDataSource', header);
alreadyExists = find(overlap, 1);
alreadyExists = obj.sources.source(alreadyExists);
error(id, ['The new data source overlaps a data source already in the gridfile.\n\n',...
    '     New Data Source: %s\nExisting Data Source: %s\n            gridfile: %s'],...
    sourceName, alreadyExists, obj.name);
end