function[X, meta] = loadInternal(obj, userDimOrder, loadIndices, s, dataSources, precision)
%% gridfile.loadInternal  Load requested data from pre-built dataSource objects
% ----------
%   [X, meta] = <strong>obj.loadInternal</strong>(userDimOrder, loadIndices, s, dataSources)
%   Returns a loaded output array and associated metadata given load
%   parameters and pre-built dataSource objects.
%
%   ... = <strong>obj.loadInternal</strong>(..., precision)
%   Specify whether the loaded array should be single or double precision.
%   If unspecified, uses a double array when either 1. Requested data is
%   not in any data source, or 2. Requested data includes double, (u)int32,
%   or (u)int64 data types. Uses a single array if all requested data is a
%   of single, char, logical, (u)int8, or (u)int16 data types.
% ----------
%   Inputs:
%       userDimOrder (vector, linear indices [nUserDims]): The locations of the
%           user-requested output dimensions in the full set of gridfile dimensions.
%       loadIndices (cell vector [nGridDims] {vector, linear indices}): The
%           elements along each gridfile dimension that are required to
%           implement the load operation. Includes all gridfile dimensions
%           in the gridfile's dimension order.
%       s (vector, linear indices [nSource]): The indices of data sources that are
%           required in order to load the requested data.
%       dataSources (cell vector [nSource] {scalar dataSource object}):
%           dataSource objects for the data sources at the specified
%           indices.
%       precision ([] | 'single' | 'double'): Indicates the required numeric precision
%           of the loaded data. If 'single' or 'double', uses the specified
%           type. If unset or an empty array, uses double unless all requested data
%           has a single, char, logical, (u)int8, or (u)int16 data type.
%
%   Outputs:
%       X (double array | single array): The loaded data array
%       meta (scalar gridMetadata object): Metadata for the loaded array.
%
% <a href="matlab:dash.doc('gridfile.loadInternal')">Documentation Page</a>

% Sizes
nSource = numel(s);

% Get the full output order
nDims = numel(obj.dims);
allDims = 1:nDims;
notInUserOrder = ~ismember(allDims, userDimOrder);
outputDimOrder = [userDimOrder, allDims(notInUserOrder)];
outputDims = obj.dims(outputDimOrder);

% Get the metadata for the output array
meta = obj.meta.index(obj.dims, loadIndices);
meta = meta.setOrder(outputDims);

% Get the size of the output array
outputSize = NaN(1, nDims);
uniqueIndices = cell(1, nDims);
for k = 1:nDims
    d = outputDimOrder(k);
    outputSize(k) = numel(loadIndices{d});

    % Get the unique set of indices being loaded.
    uniqueIndices{d} = unique(loadIndices{d});
end

% Get the numeric precision of output array
if ~exist('precision','var') || isempty(precision)
    types = strings(nSource, 1);
    for k = 1:nSource
        types(k) = dataSources{k}.dataType;
    end
    precision = obj.loadedPrecision(types);
end

% Preallocate the output array
X = NaN([outputSize, 1, 1], precision);

% Load the data from each source
for k = 1:nSource
    [Xsource, outputIndices] = loadFromSource(obj, outputDims, outputDimOrder, loadIndices, uniqueIndices, s(k), dataSources{k});
    X(outputIndices{:}) = Xsource;
end

end

%% Utility subfunctions

function[Xsource, outputIndices] = loadFromSource(obj, outputDims, outputDimOrder, loadIndices, uniqueIndices, s, dataSource)
%% Loads data from a source
%
% Inputs:
%   outputDims (string vector [nOutputDims): The ordered list of dimensions in the
%       output array.
%   outputDimOrder (vector, positive integers [nOutputDims]): The location
%       of each output dimension in the set of gridfile dimensions
%   loadIndices (cell vector [nGridDims] {vector, linear indices}): The
%       indices to load along each gridfile dimension
%   s (scalar positive integer): The index of the data source being loaded from
%   dataSource (dataSource object): A dataSource object for the source file
%
% Outputs:
%   Xsource: The data loaded from the source file
%   outputIndices (cell vector [nOutputDims] {vector, linear indices}): The
%       location of the loaded data in the output array.

% Get values for the data source. Check whether output dimensions are
% defined in the source's merged dimensions
[unmergedDims, unmergedSize, mergedDims, ~, mergeKey] = obj.sources_.unpack(s);
dimLimit = obj.dimLimit(:,:,s);
[isMergedDim, indexInMergedDims] = ismember(outputDims, mergedDims);

% Build indices
% 1. sourceIndices: Data elements to load from the source (unique/sorted
%    indices, but may be a superset of requested merged data)
% 2. keepIndices: Data elements to keep from the loaded data (requested
%    within loaded unmerged superset)
% 3. shapeIndices: Reordering of unique/sorted loaded indices to match
%    requested output
% 4. outputIndices: Location of reordered elements within the output array
[sourceIndices, keepIndices, shapeIndices, outputIndices] = buildIndices(...
    outputDimOrder, dimLimit, isMergedDim, indexInMergedDims, loadIndices, ...
    uniqueIndices, unmergedSize, mergeKey);

% Merge dimensions
% Load data (superset) from source. Permute to match output dimensions.
% Merge source dimensions. Remove unrequested data from the loaded superset
Xsource = dataSource.load(sourceIndices);
Xsource = permuteMergeSource(Xsource, unmergedDims, mergedDims, outputDims, ...
                                 isMergedDim, indexInMergedDims, mergeKey);
Xsource = Xsource(keepIndices{:});

% Apply fill value, valid range, data transform
Xsource = dataAdjustments(Xsource, obj, s);

% Reorder the loaded data to match the requested order of data elements
Xsource = Xsource(shapeIndices{:});

end
function[sourceIndices, keepIndices, shapeIndices, outputIndices] = buildIndices(...
    outputDimOrder, dimLimit, isMergedDim, indexInMergedDims, gridIndices, uniqueIndices, unmergedSourceSize, mergeKey)
%% Builds various sets of indices required to load data from a source
%
% Inputs:
%   outputDimOrder (vector, positive integers [nOutputDims]): The location
%       of each output dimension in the set of gridfile dimensions
%   dimLimit (matrix, positive integers [nGridDims, 2]): The indices
%       covered by the data source over each gridfile dimension
%   isMergedDim (logical vector [nOutputDims]): Whether each output
%       dimension is one of the data source's merged dimensions
%   indexInMergedDims (vector, positive integers [nOutputDims]): The index
%       of each output dimension in the data source's merged dimensions, or
%       0 if the output dimension is not in the source's merged dimensions.
%   gridIndices (cell vector [nGridDims] {vector, linear indices}): The
%       requested indices along each gridfile dimension
%   unmergedSourceSize (vector, positive integers [nUnmerged]): The size of
%       each non-TS unmerged source dimension.
%   mergeKey (vector, positive integers [nUnmerged]): Each element
%       corresponds to an unmerged dimension. Each element holds the index
%       of the merged dimension that contains the unmerged dimension.
%
% Outputs:
%   See notes in the indices overview

%% Preallocate / indices overview

% gridIndices
% These identify data elements within the overall gridfile. Each set of
% indices specifies the data elements that need to be loaded along one
% gridfile dimension. These are in the order of the gridfile dimensions.
... (Passed as an input)

% uniqueIndices
% These identify the unique data elements in the gridfile needed to
% implement the load operation. These indices are passed to the data source
% so that the source only loads repeated indices once. These are in the
% order of the gridfile dimensions
... (Passed as input)

% sourceIndices
% These identify data elements within the unmerged data source. Each set of
% indices specifies which data elements should be loaded along an unmerged 
% data source dimension. Because of merging, this loaded data will be a
% superset of the requested data.
nUnmerged = numel(unmergedSourceSize);
sourceIndices = repmat({1}, 1, nUnmerged);

% keepIndices
% These identify data elements within the merged, loaded data from the
% source. Each set of indices specifies which data elements to retain along
% a merged dimension of loaded data. (The unmerged loaded data is a
% superset of the requested merged data, and these indices isolate the
% requested data within the superset.) Note that merging occurs after the
% loaded data is permuted to match output dimensions. So keepIndices is in
% the order of the output dimensions.
nOutputDims = numel(outputDimOrder);
keepIndices = repmat({':'}, 1, nOutputDims);

% shapeIndices
% These reorder the loaded data (which consists of unique, sorted indices)
% to the order of indices requested for the load operation. These ordered
% indices are not necessarily sorted, and may contain repeated elements.
% The shape indices cannot be applied until dimensions are merged, so
% shapeIndices is in the order of the output dimensions
nOutputDims = numel(outputDimOrder);
shapeIndices = cell(1, nOutputDims);

% outputIndices
% These identify data elements within the returned output array. Each set
% of indices specifies the location of the final loaded data from a source
% along a merged dimension in the output array.
nOutputDims = numel(outputDimOrder);
outputIndices = cell(1, nOutputDims);

%% Build indices

% Notes:
% 1. Every gridfile dimension is in the output array
% 2. Some grid dimensions may not be in the merged data source
% 3. Some data source dimensions (both merged and raw) may not be in the gridfile

% Cycle through output dimensions. Get the source's indices along the
% dimension within the overall gridfile
for k = 1:nOutputDims
    d = outputDimOrder(k);   % location of the output dimension within the gridfile dimensions
    dimIndices = dimLimit(d,1):dimLimit(d,2);
    
    % If the dimension is not in the merge map, it is an undefined
    % singleton. Otherwise, determine which elements to load.
    if ~isMergedDim(k)
        requestedLocsInMergedSource = 1;            
    else
        m = indexInMergedDims(k);
        [toload, requestedLocsInMergedSource] = ismember(uniqueIndices{d}, dimIndices);
        requestedLocsInMergedSource = requestedLocsInMergedSource(toload);
        
        % Check if the dimension consists of multiple unmerged source
        % dimensions
        unmergedDims = find(mergeKey==m);
        nUnmerged = numel(unmergedDims);
        
        % If there are multiple unmerged dimensions, this is a merged set.
        % Get the unmerged source dimension indices
        if nUnmerged>1
            unmergedSize = unmergedSourceSize(unmergedDims);
            [sourceIndices{unmergedDims}] = ind2sub(unmergedSize, requestedLocsInMergedSource);
            
            % Only load unique unmerged indices. This may be a superset of
            % the requested data. Note which elements to retain after merging
            for u = 1:nUnmerged
                sourceIndices{unmergedDims(u)} = unique(sourceIndices{unmergedDims(u)});
            end
            loadedSubsInMergedSource = cell(1, nUnmerged);
            [loadedSubsInMergedSource{:}] = ndgrid(sourceIndices{unmergedDims});
            loadedLocsInMergedSource = sub2ind(unmergedSize, loadedSubsInMergedSource{:});
            [~, keepIndices{k}] = ismember(requestedLocsInMergedSource, loadedLocsInMergedSource);
            
        % If there is a single unmerged dimension, this is not a merged
        % set. Just load the dimension directly.
        else
            sourceIndices{unmergedDims} = requestedLocsInMergedSource;
        end
    end
    
    % Locate source data in the output array. Shape the unique/sorted
    % loaded data elements to the requested order
    gridIndicesThatWereLoaded = dimIndices(requestedLocsInMergedSource);
    [inSource, shapeIndices{k}] = ismember(gridIndices{d}, gridIndicesThatWereLoaded);
    shapeIndices{k} = shapeIndices{k}(inSource);
    outputIndices{k} = find(inSource);
end

end
function[Xsource] = permuteMergeSource(Xsource, unmergedDims, mergedDims, outputDims, isMergedDim, indexInMergedDims, mergeKey)
%% Permute source data to match output array and merge dimensions
%
% Inputs:
%   Xsource: The loaded data
%   unmergedDims (string vector): The list of the data source's unmerged dimensions
%   mergedDims (string vector): List of merged dimensions
%   outputDims (string vector): List of dimensions in the output array
%   isMergedDim (logical vector [nOutputDims]): Whether each output
%       dimension is in the list of data source merged dimensions
%   indexInMergedDims (vector, positive integers [nOutputDims]): The index
%       of each output dimension in the data source's merged dimensions, or
%       0 if the output dimension is not in the source's merged dimensions.
%   mergeKey (vector, positive integers [nUnmerged]): Each element
%       corresponds to an unmerged dimension. Each element holds the index
%       of the merged dimension that contains the unmerged dimension.
%
% Outputs:
%   Xsource: The permuted, merged data

% Track the order of all output dimensions in the source
notInSource = ~ismember(outputDims, mergedDims);
sourceDims = [unmergedDims, outputDims(notInSource)];
nSourceDims = numel(sourceDims);
order = 1:nSourceDims;

% Also track the size of the source in all dimensions
sizes = size(Xsource);
sizes(nSourceDims+1:end)=[];
sizes = [sizes, ones(1,nSourceDims-numel(sizes))];

% Track how to reorder and merge the output dimensions
reorder = [];
resize = [];
for k = 1:numel(outputDims)
    
    % If an output dimension is defined in the source's merged dimensions,
    % it could consist of multiple unmerged dimensions. Use the merge key
    % to locate the unmerged dimensions.
    if isMergedDim(k)
        m = indexInMergedDims(k);
        dim = mergeKey==m;
        
    % If an output dimension is not defined in the source, it's a singleton
    % dimension (trailing). Locate in the full list of source dimensions
    else
        dim = strcmp(outputDims(k), sourceDims);
    end
    
    % Add to the order and size
    reorder = [reorder, order(dim)]; %#ok<AGROW>
    resize = [resize, prod(sizes(dim))]; %#ok<AGROW>
end

% Move undefined singleton dimensions to the end
undefined = ~ismember(sourceDims, outputDims);
reorder = [reorder, order(undefined)];

% Permute to match output array. Reshape to merge dimensions
Xsource = permute(Xsource, reorder);
Xsource = reshape(Xsource, resize);

end
function[Xsource] = dataAdjustments(Xsource, obj, s)
%% Apply fill value, valid range, transform
%
% Inputs:
%   Xsource: The loaded source data
%   obj: gridfile object
%   s: Index of the data souce
%
% Outputs:
%   Xsource: Adjusted data

% Fill value
fill = obj.sources_.fill(s);
if ~isnan(fill)
    Xsource(Xsource==fill) = NaN;
end

% Valid Range
range = obj.sources_.range(s,:);
if ~isequal(range, [-Inf, Inf])
    Xsource(Xsource<range(1)) = NaN;
    Xsource(Xsource>range(2)) = NaN;
end

% Transformations
transform = obj.sources_.transform(s);
if ~strcmp(transform, 'none')
    params = obj.sources_.transform_params(s,:);
    if ismember(transform, ["ln","log"])
        Xsource = log(Xsource);
    elseif strcmp(transform, 'log10')
        Xsource = log10(Xsource);        
    elseif strcmp(transform, 'exp')
        Xsource = exp(Xsource);
    elseif strcmp(transform, 'power')
        Xsource = Xsource .^ params(1);
    elseif ismember(transform, ["plus","add","+"]) 
        Xsource = Xsource + params(1);
    elseif ismember(transform, ["times","multiply","*"])
        Xsource = Xsource .* params(1);
    elseif strcmp(transform, 'linear')
        Xsource = params(1) + params(2) * Xsource;
    else
        error('Unrecognized transformation');
    end
end

end
