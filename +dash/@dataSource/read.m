function[X, obj] = read( obj, mergedIndices )
%% Reads values from a data source.
%
% X = obj.read( mergedIndices )
%
% ----- Inputs -----
%
% mergedIndices: A cell array. Each element contains the indices to read 
%    for one dimension. Dimensions must be in the same order as the merged
%    dimensions. Indices should be linear indices along the dimension.
%
% ----- Outputs -----
%
% X: The values read from the data source file. Dimensions are in
%    the order of the merged dimensions.

% Preallocate
nMerged = numel(obj.mergedDims);
nUnmerged = numel(obj.unmergedDims);

unmergedIndices = cell(nUnmerged, 1);    % The requested indices in the unmerged dimensions
loadIndices = cell(nUnmerged, 1);        % The indices loaded from the source file
loadSize = NaN(nUnmerged, 1);            % The size of the loaded data grid
dataIndices = cell(nUnmerged, 1);        % The location of the requested data in the loaded data grid

keepElements = cell(nMerged, 1);         % Which data elements to retain after the dimensions
                                         % of the loaded data grid are merged.

% Get unmerged indices by converting linear indices for merged dimensions
% to subscript indices for unmerged dimensions.
for d = 1:nMerged
    isdim = find( strcmp(obj.unmergedDims, obj.mergedDims(d)) );
    siz = obj.unmergedSize(isdim);
    [unmergedIndices{isdim}] = ind2sub(siz, mergedIndices{d});
end

% Currently, all data source (.mat and netCDF based) can only load equally spaced
% values. Get equally spaced indices to load from each source.
% (This may eventually be merged into hdfSource).
for d = 1:nUnmerged
    uniqueIndices = unique(sort(unmergedIndices{d}));
    loadIndices{d} = dash.indices.equallySpaced(uniqueIndices);
    loadSize(d) = numel(loadIndices{d});

    % Determine the location of requested data elements in the loaded data
    % grid.
    start = loadIndices{d}(1);
    stride = 1;
    if numel(loadIndices{d})>1
        stride = loadIndices{d}(2) - loadIndices{d}(1);
    end
    dataIndices{d} = ((unmergedIndices{d}-start) / stride) + 1;
end

% Load the values from the data source
[X, obj] = obj.load( loadIndices );

% Track which dimensions become singletons via merging
remove = NaN(1, nUnmerged-nMerged);

% Permute dimensions being merged to the front
for d = 1:nMerged
    order = 1:nUnmerged;
    isdim = strcmp(obj.unmergedDims, obj.mergedDims(d));
    order = [order(isdim), order(~isdim)];
    isdim = find(isdim);
    if ~isequal(order,1)
        X = permute(X, order);
    end

    % Reshape dimensions being merged into a single dimension. Use
    % singletons for secondary merged dimensions to preserve dimension order
    siz = size(X);
    nDim = numel(isdim);
    siz(end+1:nDim) = 1;

    newSize = [prod(siz(1:nDim)), ones(1,nDim-1), siz(nDim+1:end)];
    X = reshape(X, newSize);

    % Unpermute and note if any dimensions should be removed
    [~, reorder] = sort(order);
    if ~isequal(reorder, 1)
        X = permute( X, reorder );
    end

    k = find(isnan(remove), 1, 'first');
    remove(k:k+nDim-2) = isdim(2:end);

    % Convert data indices for unmerged dimensions to linear indices for
    % the merged dimension
    siz = loadSize(isdim);
    if numel(isdim) > 1
        keepElements{d} = sub2ind(siz, dataIndices{isdim});
    else
        keepElements{d} = dataIndices{isdim};
    end
end

% Remove singletons resulting from the merge. 
dimOrder = 1:nUnmerged;
order = [dimOrder(~ismember(dimOrder,remove)), remove];
if ~isequal(order, 1)
    X = permute(X, order);
end

% Remove any unrequested data elements that were loaded to
% fulfill equal spacing requirements
X = X(keepElements{:});

% Convert fill value to NaN
if ~isnan(obj.fill)
    X(X==obj.fill) = NaN;
end

% Convert values outside the valid range to NaN
if ~isequal(obj.range, [-Inf Inf])
    valid = (X>=obj.range(1)) & (X<=obj.range(2));
    X(~valid) = NaN;
end

% Apply linear transformation
if ~isequal(obj.convert, [1 0])
    X = obj.convert(1)*X + obj.convert(2);
end

end
