function[X, sources] = loadMembers(obj, subMembers, s, grid, sources, progress)

% Get the index limits for the entire set of variables
indices = s.indices;
[nEns, nSub] = size(subMembers);
limits = NaN(nSub, 2);
for k = 1:nSub
    i = s.d(k);
    dimIndex = obj.indices{i};
    limits(k,1) = min(dimIndex(subMembers(:,k))) + min(s.addIndices{k});
    limits(k,2) = max(dimIndex(subMembers(:,k))) + max(s.addIndices{k});
    indices{i} = (limits(k,1):limits(k,2))';
end

% Preallocate
nState = prod(s.siz);
X = NaN(nState, nEns);

% Attempt to load all required data at once
nDims = numel(obj.dims);
try
    [Xall, ~, sources] = grid.repeatedLoad(1:nDims, indices, sources);
    
    % Process each ensemble member
    indices = repmat({':'}, [1, nDims]);
    for m = 1:nEns
        
        % Extract the ensemble member from the loaded array
        for k = 1:nSub
            i = s.d(k);
            indices{i} = obj.indices{i}(subMembers(m,k)) + s.addIndices{k} - limits(k,1) + 1;
        end
        Xm = Xall(indices{:});
        
        % Process the means and save
        X(:,m) = processMember(obj, Xm, s, nDims);
        progress.update;
    end
    
% If unsuccessful, load one ensemble member at a time from the .grid file
catch
    for m = 1:nEns
        for k = 1:nSub
            i = s.d(k);
            s.indices{i} = obj.indices{i}(subMembers(m,k)) + s.addIndices{k};
        end
        [Xm, ~, sources] = grid.repeatedLoad(1:nDims, s.indices, sources);
        
        % Process the means and save
        X(:,m) = processMember(obj, Xm, s, nDims);
        progress.update;
    end
end

end

% Take the means over an ensemble member
function[Xm] = processMember(obj, Xm, s, nDims)

% Separate means from sequences
Xm = reshape(Xm, s.siz);

% If taking a mean over a dimension, get the weights
for k = 1:nDims
    if obj.takeMean(k)
        w = obj.weightCell{k};
        
        % If omitting NaN, propagate weights over matrix and infill NaN
        if obj.omitnan(k)
            nanIndex = isnan(Xm);
            if any(nanIndex, 'all')
                wSize = s.siz;
                wSize( s.meanDims(obj.takeMean(1:k)) ) = 1;
                w = repmat(w, wSize);
                w(nanIndex) = NaN;
            end
        end
        
        % Take the weighted mean
        Xm = sum(w.*Xm, s.meanDims(k), s.nanflag(k)) ./ sum(w, s.meanDims(k), s.nanflag(k));
    end
end

% Convert to state vector
Xm = Xm(:);

end