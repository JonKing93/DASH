function[X, meta, sources] = repeatedLoad(obj, userDimOrder, userIndices, sources)
%% gridfile.repeatedLoad  Load data from a gridfile and return built data sources
%
% dimOrder: The of output dimensions relative to gridfile dimensions

% Default
if ~exist('sources','var') || isempty(sources)
    sources = cell(obj.nSource, 1);
end

%% Organize the full output array
% The user might not provide input for every gridfile dimension. However,
% the output array should include values for every gridfile dimension.
% These steps help organize values for that full output array.

% Get the full order of dimensions in the output array
nDims = numel(obj.dims);
allDims = 1:nDims;
notInUserRequest = ~ismember(allDims, userDimOrder);
outputDimOrder = [userDimOrder, allDims(notInUserRequest)];
outputDims = obj.dims(outputDimOrder);

% Preallocate 1. dimension sizes, 2. loadIndices, 3. loadLimits (used to 
% determine necessary data sources) for the output array. Also initialize
% output array metadata.
outputSize = NaN(1, nDims);
loadIndices = cell(1, nDims);
loadLimit = NaN(nDims, 2);
meta = obj.meta;

% Copy any user indices directly into the set of loadIndices
nUserDims = numel(userDimOrder);
loadIndices(1:nUserDims) = userIndices;

% Cycle through the dimensions of the output array. Note the index of each
% dimension in the output array (k), and its index in the gridfile (d).
% (Cycle through all dimensions - including user input - because user may
% not have provided indices for all input dimensions).
for k = 1:nDims
    d = outputDimOrder(k);
    dim = obj.dims(d);
    
    % If there are no indices, load the entire dimension. (Either 1. User
    % input the dimension but no indices, or 2. User did not input dimension)
    if isempty(loadIndices{k})
        loadIndices{k} = 1:obj.size(d);
    end
    
    % Get the size, loadLimits, and metadata for each dimension
    outputSize(k) = numel(loadIndices{k});
    loadLimit(d,:) = dash.limits(loadIndices{k});
    metaValues = meta.(dim)(loadIndices{k}, :);
    meta = meta.edit(dim, metaValues);
end
    
% Preallocate the output array. (add trailing singletons for grids with 0
% or 1 dimensions)
X = NaN([outputSize, 1, 1]);


%% Setup to load data from data sources
% Determine which data sources are actually needed. Determine location of
% data in sources, as well as source data in the output array

% Check each data source to see if it contains required data
tooLow = any(loadLimit(:,2) < obj.dimLimit(:,1,:), 1);
tooHigh = any(loadLimit(:,1) > obj.dimLimit(:,2,:), 1);
useSource = find( ~tooLow & ~tooHigh );

% Cycle through the necessary data sources. Get load and merge values
for k = 1:numel(useSource)
    s = useSource(k);
    [sourceDims, siz, mergedDims, ~, mergeKey] = obj.sources_.unpack(s);
    nSourceDims = numel(sourceDims);
    
    % Get a data source object to load data for each source. Build the
    % object if not provided.
    if isempty(sources{s})
        sources{s} = obj.sources_.build(s);
    end
    dataSource = sources{s};
     
    % Preallocate 1. the location of requested data in the sources, and 
    % 2. the location of loaded source data in the output array
    sourceIndices = repmat({1}, 1, nSourceDims);
    outputIndices = cell(1, nDims);
    
    % In the next steps, we will fill the source and output indices.
    %
    % Notes:
    % 1. Every gridfile dimension is in the output array
    % 2. Some grid dimensions may not be in the merged data source
    % 3. Some data source dimensions (both merged and raw) may not be in the gridfile
    
    % Check whether output dimensions are defined in the source
    [isMergedDim, indexInMergedDims] = ismember(outputDims, mergedDims);
    
    % Cycle through output dimensions. Get the source's indices along the dimension
    for j = 1:nDims
        d = outputDimOrder(j);
        dimIndices = obj.dimLimit(d,1,s):obj.dimLimit(d,2,s);
        
        % If the dimension is not in the merge map, it is an undefined
        % singleton. If defined, determine which elements to load.
        if ~isMergedDim(j)
            locsInMergedSource = 1;            
        else
            m = indexInMergedDims(j);
            [toload, locsInMergedSource] = ismember(loadIndices{j}, dimIndices);
            locsInMergedSource = locsInMergedSource(toload);
            
            % If this is a raw unmerged dimension, load directly from the
            % source. Otherwise, unmerge the dimension to get source indices
            merged = mergeKey==m;
            if sum(merged)==1
                sourceIndices{merged} = locsInMergedSource;                
            else
                unmergedSize = siz(merged);
                [sourceIndices{merged}] = ind2sub(unmergedSize, locsInMergedSource);
            end
        end
        
        % Locate source data in the output array
        gridIndicesThatWereLoaded = dimIndices(locsInMergedSource);
        [~, outputIndices{j}] = ismember(gridIndicesThatWereLoaded, loadIndices{j});
    end
    
    %% Manipulate loaded source data
    
    % Load the data from the source
    Xsource = dataSource.load(sourceIndices);
    
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
    
%% Match loaded data to output array    
    
    % Track the order of all output dimensions in the source
    notInSource = ~ismember(outputDims, mergedDims);
    sourceDims = [mergedDims, outputDims(notInSource)];
    nSourceDims = numel(sourceDims);
    order = 1:nSourceDims;
    
    % Also track the size of the source in all dimensions
    sizes = size(Xsource);
    sizes(nSourceDims+1:end)=[];
    sizes = [sizes, ones(1,nSourceDims-numel(sizes))]; %#ok<AGROW>
    
    % Track how to reshape and reorder to the output dimensions
    reorder = [];
    resize = [];
    for j = 1:nDims
        
        % Dimensions defined in the source are in the merge key. Anything
        % else can be found in the source dimension list
        if isMergedDim(j)
            m = indexInMergedDims(j);
            dim = mergeKey==m;
        else
            dim = strcmp(outputDims(j), sourceDims);
        end
        
        % Add to the order and size
        reorder = [reorder, order(dim)]; %#ok<AGROW>
        resize = [resize, prod(sizes(dim))]; %#ok<AGROW>
    end
    
    % Move undefined singleton dimensions to the end
    undefined = ~ismember(sourceDims, outputDims);
    reorder = [reorder, order(undefined)]; %#ok<AGROW>
    
    % Permute, merge, add to output array
    Xsource = permute(Xsource, reorder);
    Xsource = reshape(Xsource, resize);
    X(outputIndices{:}) = Xsource;
end
            
end