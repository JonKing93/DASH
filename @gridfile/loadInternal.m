function[X, meta] = loadInternal(obj, userDimOrder, loadIndices, s, dataSources)
%% gridfile.loadInternal  Load gridfile data from pre-built dataSource objects
% ----------
%   [X, meta] = obj.loadInternal(userDimOrder, loadIndices, s, dataSources)
%   Returns a loaded output array and associated metadata given load
%   parameters and pre-built dataSource objects.
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
%       dataSources (cell vector [nSources] {scalar dataSource object}):
%           dataSource objects for the data sources at the specified
%           indices.
%
%   Outputs:
%       X: The loaded data array
%       meta (scalar gridMetadata object): Metadata for the loaded array.
%
% <a href="matlab:dash.doc('gridfile.loadInternal')">Documentation Page</a>

% Get the full output order
nDims = numel(obj.dims);
allDims = 1:nDims;
notInUserOrder = ~ismember(allDims, userDimOrder);
outputDimOrder = [userDimOrder, allDims(notInUserOrder)];
outputDims = obj.dims(outputDimOrder);

% Get the metadata for the output array
meta = obj.meta.index(outputDims, loadIndices);
meta = meta.setOrder(outputDims);

meta = obj.meta;
for k = 1:nDims
    d = outputDimOrder(k);
    dim = obj.dims(d);
    metaValues = meta.(dim)(loadIndices{d}, :);
    meta = meta.edit(dim, metaValues);
end
meta = meta.setOrder(outputDims);

% Get the size of the output array
outputSize = NaN(1, nDims);
for k = 1:nDims
    d = outputDimOrder(k);
    outputSize(k) = numel(loadIndices{d});
end

% Preallocate the output array
X = NaN([outputSize, 1, 1]);

% Load the data from each source
for k = 1:numel(s)
    [Xsource, outputIndices] = loadFromSource(obj, outputDims, outputDimOrder, loadIndices, s(k), dataSources{k});
    X(outputIndices{:}) = Xsource;
end

end

% Utility subfunctions
function[Xsource, outputIndices] = loadFromSource(obj, outputDims, outputDimOrder, loadIndices, s, dataSource)

% Get values for the data source. Check whether output dimensions are
% defined in the source's merged dimensions
[unmergedDims, unmergedSize, mergedDims, ~, mergeKey] = obj.sources_.unpack(s);
dimLimit = obj.dimLimit(:,:,s);
[isMergedDim, indexInMergedDims] = ismember(outputDims, mergedDims);

% 1. Data elements to load from the source (a superset of requested data)
% 2. Data elements to keep from the loaded data (requested within loaded superset)
% 3. Location of kept elements within the output array
[sourceIndices, keepIndices, outputIndices] = buildIndices(...
    outputDimOrder, dimLimit, isMergedDim, indexInMergedDims, loadIndices, unmergedSize, mergeKey);

% Load data (superset) from source. Permute to match output dimensions.
% Merge source dimensions. Remove unrequested data from the loaded superset
Xsource = dataSource.load(sourceIndices);
Xsource = permuteMergeSource(Xsource, unmergedDims, mergedDims, outputDims, ...
                                 isMergedDim, indexInMergedDims, mergeKey);
Xsource = Xsource(keepIndices{:});

% Apply fill value, valid range, data transform
Xsource = dataAdjustments(Xsource, obj, s);

end
function[sourceIndices, keepIndices, outputIndices] = buildIndices(...
    outputDimOrder, dimLimit, isMergedDim, indexInMergedDims, gridIndices, unmergedSourceSize, mergeKey)

%% Preallocate / indices overview

% gridIndices
% These identify data elements within the overall gridfile. Each set of
% indices specifies the data elements that need to be loaded along one
% gridfile dimension. 
... (Passed as an input)

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
    d = outputDimOrder(k);
    dimIndices = dimLimit(d,1):dimLimit(d,2);
    
    % If the dimension is not in the merge map, it is an undefined
    % singleton. Otherwise, determine which elements to load.
    if ~isMergedDim(k)
        requestedLocsInMergedSource = 1;            
    else
        m = indexInMergedDims(k);
        [toload, requestedLocsInMergedSource] = ismember(gridIndices{d}, dimIndices);
        requestedLocsInMergedSource = requestedLocsInMergedSource(toload);
        
        % Check if the dimension consists of multiple unmerged source
        % dimensions
        unmergedDims = find(mergeKey==m);
        nUnmerged = numel(unmergedDims);
        
        % If there are multiple unmerged dimensions, get the unmerged source dimension indices
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
            
        % If a single unmerged dimension, just load directly
        else
            sourceIndices{unmergedDims} = requestedLocsInMergedSource;
        end
    end
    
    % Locate source data in the output array
    gridIndicesThatWereLoaded = dimIndices(requestedLocsInMergedSource);
    [~, outputIndices{k}] = ismember(gridIndicesThatWereLoaded, gridIndices{d});
end

end
function[Xsource] = permuteMergeSource(Xsource, unmergedDims, mergedDims, outputDims, isMergedDim, indexInMergedDims, mergeKey)

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

% Fill value
fill = obj.sources_.fill(s);
if ~isnan(fill)
    Xsource(fill) = NaN;
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
    if strcmp(transform, 'ln') || (strcmp(transform,'log') && strcmp(params(1), 'e'))
        Xsource = log(Xsource);
    elseif strcmp(transform, 'exp')
        Xsource = exp(Xsource);
    elseif strcmp(transform, 'log') && params(1)==10
        Xsource = log10(Xsource);
    elseif strcmp(transform, 'power')
        Xsource = Xsource .^ params(1);
    elseif strcmp(transform, 'plus')
        Xsource = Xsource + params(1);
    elseif strcmp(transform, 'times')
        Xsource = Xsource .* params(1);
    elseif strcmp(transform, 'linear')
        Xsource = params(1) + params(2) * Xsource;
    else
        error('Unrecognized transformation');
    end
end

end
