function[X] = buildEnsemble(obj, member)
%% Builds an ensemble for the stateVectorVariable
%
% X = obj.buildEnsemble(draws)
%
% ----- Inputs -----
%
% member: The linear index that specifies which ensemble member to build.
%    Ensemble members are indexed by iterating through ensemble dimension
%    elements in column major order.
%
% ----- Outputs -----
%
% X: The ensemble for the variable. A numeric matrix

%%%%%% Currently building architecture for a single draw

% Initialize the load indices with any state indices
nDims = numel(obj.dims);
indices = cell(1, nDims);
indices(obj.isState) = obj.indices(obj.isState);

% Convert the draw index into reference indices for the ensemble dimensions
siz = obj.ensSize(~obj.isState);
[indices{~obj.isState}] = ind2sub(siz, member);

% Get mean indices for each ensemble dimension
d = find(~obj.isState);
for k = 1:numel(d)
    meanIndices = obj.mean_Indices{d(k)};
    if isempty(meanIndices)
        meanIndices = 0;
    end
    
    % Propagate mean indices over sequence indices. Add to reference indices
    ensIndices = meanIndices + obj.seqIndices{d(k)}';
    ensIndices = ensIndices(:);
    indices{d(k)} = indices{d(k)} + ensIndices;
end

% Load the data from the .grid file and record its size
grid = gridfile(obj.file);
X = grid.load(obj.dims, indices);
siz = obj.stateSize .* obj.meanSize;

% Get values for means
meanDims = 1:nDims;
obj.meanSize(isnan(obj.meanSize)) = 1;
nanflag = repmat("includenan", [1, nDims]);
nanflag(obj.omitnan) = "omitnan";

% Reshape sequences
for d = 1:nDims
    if ~obj.isState(d) && obj.stateSize(d)>1
        siz = [siz(1:d-1), obj.meanSize(d), obj.stateSize(d), siz(d+1:end)];
        X = reshape(X, siz);
        meanDims(d+1:end) = meanDims(d+1:end)+1;
    end
    
    % If taking a mean, permute weights for singleton expansion
    if obj.takeMean(d)
        if isempty(obj.weightCell{d})
            obj.weightCell{d} = ones(obj.meanSize(d), 1);
        end
        w = permute(obj.weightCell{d}, [2:meanDim(d), 1]);
        
        % If omitting NaN, propagate weights over the matrix and infill NaN
        if obj.omitnan(d)
            nanIndex = isnan(X);
            if any(nanIndex, 'all')
                weightSize = siz;
                weightSize(meanDims(d)+1) = 1;
                w = repmat(w, weightSize);
                w(nanIndex) = NaN;
            end
        end
        
        % Take mean.
        X = sum(w.*X, meanDims(d), nanflag(d)) ./ sum(w, meanDims(d), nanflag(d));
    end
end

end