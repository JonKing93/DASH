function[loadDex, keepDex] = getLoadingIndices( var )

% Create a cell of indices to load data from the .grid file
nDim = numel(var.dimID);
loadDex = cell(1,numel(nDim));

% Partial loading from .mat files is only supported for indices with
% uniform spacing. So, when the sample indices for a .grid file are
% unevenly spaced, the entire interval of data between the indices is
% loaded.
%
% After the entire interval is loaded, the data is indexed so that we will
% only keep the values associated with the sampling indces.

% Initialize a cell of indices to index which loaded values should be kept.
keepDex = repmat({':'}, [1,nDim] );

% For each dimension
for d = 1:numel(var.dimID)
    
    % For state dimensions, the smallest unit of contiguous loaded data is
    % a set of state indices.
    if var.isState(d)
        loadDex{d} = var.indices{d};
        
    % For ensemble dimensions, the smallest set of contiguous loaded data
    % is a set of mean indices for a single sequence element
    else
        loadDex{d} = var.meanDex{d};
    end
    
    % Sort the indices so we can test for uniform spacing
    loadDex{d} = sort(loadDex{d});
    
    % If the indices are unevenly spaced
    if numel(loadDex{d})>1 && numel(unique(diff(loadDex{d})))>1
        
        % Get the full interval of indices
        interval = loadDex{d}(1):loadDex{d}(end);
        
        % Only keep points on this interval that are associated with
        % sampling indices.
        keepDex{d} = find( ismember( loadDex{d}, interval ) );
        
        % Load everything on the interval between the indices
        loadDex{d} = interval;
    end
end

end
        
        
        
        