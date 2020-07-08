function[X, meta, sources] = repeatedLoad(obj, inputOrder, inputIndices, sources)
%% Loads values from the data sources managed by a .grid file. Optimizes
% the process for repeated load operations, which is a common task
% when building state vector ensembles. This is a low level method.
% It provides no little error checking and is not intended for users. For a
% user-friendly method see "gridfile.load".
%
% [X, meta, sources] = obj.repeatedLoad(inputOrder, inputIndices, sources)
%
% ----- Inputs -----
%
% inputOrder: An ordering used to match .grid file dimensions to the 
%    order of dimensions requested for the output array.
%
% inputIndices: A cell vector with an element for each dimension specified
%    in inputOrder. Each element specifies the LINEAR indices to load for
%    that dimension.
%
% sources: A cell vector with an element for each data source in the .grid
%    file. May contain pre-built dataSource objects to hasten repeated
%    loads. Use an empty array if not performing repeated loads.
%
% ----- Outputs -----
%
% X: The loaded data values.
%
% meta: Metadata for the loaded data values.
%
% sources: An array holding any dataSource objects built for previous load
%    operations.

% Preallocate indices for all dimensions, the size of the output grid, and
% the dimension limits of the requested values, and the output metadata
nDims = numel(obj.dims);
indices = cell(nDims, 1);
outputSize = NaN(1, nDims);
loadLimit = NaN(nDims, 2); 
meta = obj.meta;

% Get indices for all .grid dimensions
indices(inputOrder) = inputIndices;
for d = 1:nDims
    if isempty(indices{d})
        indices{d} = 1:obj.size(d);
    end
    
    % Determine the size of the dimension, and dimensions limits
    outputSize(d) = numel(indices{d});
    loadLimit(d,:) = [min(indices{d}), max(indices{d})];
    
    % Limit the metadata to these indices
    meta.(obj.dims(d)) = meta.(obj.dims(d))(indices{d},:);
end

% Preallocate the output
X = NaN( outputSize );

% Check each data source to see if it contains any requested data
tooLow = any(all(loadLimit < obj.dimLimit, 2), 1);
tooHigh = any(all(loadLimit > obj.dimLimit, 2), 1);
useSource = find(~tooLow & ~tooHigh);

% Build a data source object for each source with required data or load a
% pre-built object.
for s = 1:numel(useSource)
    if isempty(sources) || isempty(sources{useSource(s)})
        [type, file, var, unmergedDims] = obj.collectPrimitives(["type","file","var","unmergedDims"], useSource(s));
        unmerged = gridfile.commaDelimitedToString( unmergedDims );
        sources{useSource(s)} = dataSource.new( type, file, var, unmerged );
    end
    source = sources{useSource(s)};    
    
    % Preallocate the location of requested data relative to the source
    % grid, and relative to the output grid
    nMerged = numel(source.mergedDims);
    sourceIndices = cell(1, nMerged);
    outputIndices = repmat({':'}, [1,nDims]);
    
    % Get the .grid dimension indices covered by the data source
    for d = 1:nDims
        limit = obj.dimLimit(d,:,useSource(s));
        dimIndices = limit(1):limit(2);
        
        % Get the indices of the requested data relative to the source grid
        % and the output grid
        [ismem, sourceDim] = ismember(obj.dims(d), source.mergedDims);
        if ismem
            [~, loc] = ismember( indices{d}, dimIndices );
            sourceIndices{sourceDim} = loc(loc~=0);
            [~, outputIndices{d}] = ismember( dimIndices(sourceIndices{sourceDim}), indices{d} );
        end
    end
    
    % Load the data from the data source
    Xsource = source.read( sourceIndices );
    
    % Permute to match the order of the .grid dimensions. Add to output
    dimOrder = 1:nDims;
    [~, gridOrder] = ismember( obj.dims, source.mergedDims );
    gridOrder(gridOrder==0) = dimOrder(~ismember(dimOrder,gridOrder));
    X(outputIndices{:}) = permute(Xsource, gridOrder);
end

% Permute to match the requested dimension order
dimOrder = 1:nDims;
inputOrder = [dimOrder(inputOrder), dimOrder(~ismember(dimOrder,inputOrder))];
X = permute(X, inputOrder);
meta = orderfields(meta, inputOrder);
dims = obj.dims(inputOrder);

% Remove any undefined singleton dimensions from the data and the metadata
isdefined = obj.isdefined(inputOrder);
order = [find(isdefined), find(~isdefined)];
X = permute(X, order);
meta = rmfield( meta, dims(~isdefined) );
    
end