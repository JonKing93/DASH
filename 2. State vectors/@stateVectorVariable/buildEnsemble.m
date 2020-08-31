function[X] = buildEnsemble(obj, members, sources)
%% Builds an ensemble for the stateVectorVariable
%
% X = obj.buildEnsemble(members)
%
% ----- Inputs -----
%
% member: The linear index that specifies which ensemble member to build.
%    Ensemble members are indexed by iterating through ensemble dimension
%    elements in column major order.
%
% sources: An array for data sources being called in a gridfile repeated
%    load. See gridfile.review
%
% ----- Outputs -----
%
% X: The ensemble for the variable. A numeric matrix. (nState x nEns)

%% Means

% Get nanflag and fill unspecified meanSize
nDims = numel(obj.dims);
nanflag = repmat("includenan", [1 nDims]);
nanflag(obj.omitnan) = "omitnan";

% Track the size and location of dimensions for taking means
obj.meanSize(isnan(obj.meanSize)) = 1;
siz = obj.stateSize .* obj.meanSize;
meanDims = 1:nDims;

% Get the weights for each dimension with a mean
for d = 1:nDims
    if obj.takeMean(d)
        if isempty(obj.weightCell{d})
            obj.weightCell{d} = ones(obj.meanSize(d), 1);
        end
        obj.weightCell{d} = permute(obj.weightCell{d}, [2:meanDims(d), 1]);
    end
end

%% Ensemble dimensions: indices and sequences

% Initialize load indices with state indices
indices = cell(1, nDims);
indices(obj.isState) = obj.indices(obj.isState);

% Convert the linear ensemble member index into a subscripted ensemble
% member index. Preallocate the add indices for means/sequences.
subMembers = indices(~obj.isState);
[subMembers{:}] = ind2sub(obj.ensSize(~obj.isState), members);
addIndices = cell(1, numel(subMembers));

% Get mean indices
d = find(~obj.isState);
for k = 1:numel(d)
    meanIndices = obj.mean_Indices{d(k)};
    if isempty(meanIndices)
        meanIndices = 0;
    end
    
    % Propagate over sequences to get add indices
    addIndices{k} = meanIndices + obj.seqIndices{d(k)}';
    addIndices{k} = addIndices{k}(:);
    
    % Note if size or mean dimensions change for sequences
    if obj.stateSize(d(k))>1
        siz = [siz(1:d(k)-1), obj.meanSize(d(k)), obj.stateSize(d(k)), siz(d(k)+1:end)];
        meanDims(d(k)+1:end) = meanDims(d(k)+1:end)+1;
    end
end

%% Load individual ensemble members

% Create the gridfile and preallocate the ensemble
grid = gridfile(obj.file);
nMembers = numel(members);
X = NaN( prod(obj.stateSize), nMembers );

% Get load indices for each ensemble member
for m = 1:nMembers
    for k = 1:numel(d)
        indices{d(k)} = obj.indices{d(k)}(subMembers{k}(m)) + addIndices{k};
    end
    
    % Load the data. Reshape sequences
    [Xm, ~, sources] = grid.repeatedLoad(1:nDims, indices, sources);
    Xm = reshape(Xm, siz);
    
    % If taking a mean over a dimension, get the weights
    for k = 1:nDims
        if obj.takeMean(k)
            w = obj.weightCell{k};
            
            % If omitting NaN, propagate weights over matrix and infill NaN
            if obj.omitnan(k)
                nanIndex = isnan(Xm);
                if any(nanIndex, 'all')
                    wSize = siz;
                    wSize( meanDims(find(obj.takeMean(1:k))) ) = 1; %#ok<FNDSB>
                    w = repmat(w, wSize);
                    w(nanIndex) = NaN;
                end
            end
            
            % Take the mean
            Xm = sum(w.*Xm, meanDims(k), nanflag(k)) ./ sum(w, meanDims(k), nanflag(k));
        end
    end
    
    % Add the vector to the ensemble
    X(:,m) = Xm(:);
end

end