function[start, count, stride, keep] = loadingIndices( obj )
% Implement efficient loading behavior from grid file

% Preallocate
nVar = numel(obj.var);
nDim = numel(obj.var(1).dimID);
start = NaN( nVar, nDim );
count = NaN( nVar, nDim );
stride = ones( nVar, nDim );
keep = cell( nVar, nDim );

% Get the smallest set of indices in each dimension
for v = 1:nVar
    var = obj.var(v);
    for d = 1:nDim
        if var.isState(d)
            index = var.indices{d};
        else
            index = var.meanDex{d};
        end
        
        % Determine if evenly spaced. If so, use the appropriate stride. 
        % If not, load the entire interval.
        loadInterval = index;
        spacing = unique( diff(index) );
        if numel(index)>1 && numel(spacing)>1
            loadInterval = index(1):index(end);
        elseif numel(index) > 1
            stride(v,d) = spacing;
        end
        
        % Update the start and count. Only keep loaded values associated
        % with indices. Can't know the start of ensemble dimensions
        if var.isState(d)
            start(v,d) = loadInterval(1);
        end
        count(v,d) = numel( loadInterval );
        [~, keep{v,d}] = ismember( index, loadInterval );
    end
end

end
        