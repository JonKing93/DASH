function[scs, keep] = loadingIndices( obj )

% Preallocate
nDim = numel( obj.dimID );
scs = [NaN(2, nDim ); ones(1,nDim)];
keep = cell(nDim,1);

for d = 1:nDim
    if obj.isState(d)
        index = obj.indices{d};
    else
        index = obj.meanDex{d};
    end

    % Check if evenly spaced. If not load the entire interval
        loadInterval = index;
        spacing = unique( diff(index) );
        if numel(index)>1 && numel(spacing)>1
            loadInterval = index(1):index(end);
        elseif numel(index) > 1
            scs(3,d) = spacing;
        end

    % Update the start and count. Only keep correct values
    if obj.isState(d)
        scs(1,d) = loadInterval(1);
    end
    scs(2,d) = numel( loadInterval );
    [~, keep{d}] = ismember( index, loadInterval );
end

end