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
[~, sourceSize, mergedDims, ~, mergeKey] = obj.sources_.unpack(s);
dimLimit = obj.dimLimit(:,:,s);
[isMergedDim, indexInMergedDims] = ismember(outputDims, mergedDims);

% Get 1. location of data in source, and 2. location of data in output array
[sourceIndices, outputIndices] = sourceOutputIndices(...
    outputDimOrder, dimLimit, isMergedDim, indexInMergedDims, loadIndices, sourceSize, mergeKey);

% Load data. Apply fill, range, transform. Permute to match output array
Xsource = dataSource.load(sourceIndices);
Xsource = dataAdjustments(Xsource, obj, s);
Xsource = permuteSource(Xsource, outputDims, mergedDims, isMergedDim, indexInMergedDims);

end
function[sourceIndices, outputIndices] = sourceOutputIndices(...
    outputDimOrder, dimLimit, isMergedDim, indexInMergedDims, loadIndices, sourceSize, mergeKey)

% Preallocate
nSourceDims = numel(sourceSize);
nOutputDims = numel(outputDimOrder);
sourceIndices = repmat({1}, 1, nSourceDims);
outputIndices = cell(1, nOutputDims);

% In the next steps, we will fill the source and output indices.
%
% Notes:
% 1. Every gridfile dimension is in the output array
% 2. Some grid dimensions may not be in the merged data source
% 3. Some data source dimensions (both merged and raw) may not be in the gridfile

% Cycle through output dimensions. Get the source's indices along the
% dimension within the overall gridfile
for k = 1:ndims
    d = outputDimOrder(k);
    dimIndices = dimLimit(d,1):dimLimit(d,2);
    
    % If the dimension is not in the merge map, it is an undefined
    % singleton. If defined, determine which elements to load.
    if ~isMergedDim(k)
        locsInMergedSource = 1;            
    else
        m = indexInMergedDims(k);
        [toload, locsInMergedSource] = ismember(loadIndices{k}, dimIndices);
        locsInMergedSource = locsInMergedSource(toload);
        
        % If the merged dimension consists of a single unmerged dimension,
        % load it directly from the source. Otherwise, unmerge the output
        % dimension to get unmerged source dimension indices.
        merged = mergeKey==m;
        if sum(merged)==1
            sourceIndices{merged} = locsInMergedSource;                
        else
            unmergedSize = sourceSize(merged);
            [sourceIndices{merged}] = ind2sub(unmergedSize, locsInMergedSource);
        end
    end
    
    % Locate source data in the output array
    gridIndicesThatWereLoaded = dimIndices(locsInMergedSource);
    [~, outputIndices{k}] = ismember(gridIndicesThatWereLoaded, loadIndices{k});
end

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
function[Xsource] = permuteSource(Xsource, outputDims, mergedDims, isMergedDim, indexInMergedDims)

% Track the order of all output dimensions in the source
notInSource = ~ismember(outputDims, mergedDims);
sourceDims = [mergedDims, outputDims(notInSource)];
nSourceDims = numel(sourceDims);
order = 1:nSourceDims;

% Also track the size of the source in all dimensions
sizes = size(Xsource);
sizes(nSourceDims+1:end)=[];
sizes = [sizes, ones(1,nSourceDims-numel(sizes))];

% Track how to reshape and reorder to the output dimensions
reorder = [];
resize = [];
for k = 1:nDims
    
    % Dimensions defined in the source are in the merge key. Anything
    % else can be found in the source dimension list
    if isMergedDim(k)
        m = indexInMergedDims(k);
        dim = mergeKey==m;
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

% Permute and reshape to match output array
Xsource = permute(Xsource, reorder);
Xsource = reshape(Xsource, resize);

end