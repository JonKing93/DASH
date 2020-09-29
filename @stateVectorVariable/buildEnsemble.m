function[out] = buildEnsemble(obj, subMembers, dims, grid, sources, ens, svRows, showprogress)
%% Builds an ensemble for the stateVectorVariable
%
% X = obj.buildEnsemble(subMembers, dims, grid, sources, [], [], showprogress)
% Builds an ensemble and returns the array directly as output.
%
% hasnan = obj.buildEnsemble(subMembers, dims, grid, sources, ens, svRows, showprogress)
% Builds an ensemble and saves it to a .ens file. Returns an array
% indicating if any ensemble members contain NaN.
%
% ----- Inputs -----
%
% subMembers: A matrix of subscripted ensemble member indices. Each row
%    holds the subscripted indices for one ensemble member. Each column is
%    the indices for an ensemble dimension.
%
% dims: The names of ensemble dimensions in the order that appear in the
%    columns of subMembers. A string vector or cellstring vector.
%
% grid: Gridfile object to load the data
%
% sources: An array for data sources being called in a gridfile repeated
%    load. See gridfile.review
%
% ens: Matfile object if writing to file. Empty if returning output array.
%
% svRows: Rows of the variable in the complete state vector if writing to 
%    file. Empty if returning output array.
%
% showprogress: Scalar logical that indicates whether to display a progress
%    bar.
%
% ----- Outputs -----
%
% X: The ensemble for the variable. A numeric matrix. (nState x nEns)
%
% hasnan: A logical row vector indicating which ensemble members contain NaN

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
for k = 1:nDims
    if obj.takeMean(k)
        if isempty(obj.weightCell{k})
            obj.weightCell{k} = ones(obj.meanSize(k), 1);
        end
        
        % Permute for singleton expansion
        order = 1:max(2, meanDims(k));
        order(meanDims(k)) = 1;
        order(1) = meanDims(k);
        obj.weightCell{k} = permute(obj.weightCell{k}, order);
    end
end

%% Ensemble dimensions: indices and sequences

% Initialize load indices with state indices.
indices = cell(1, nDims);
indices(obj.isState) = obj.indices(obj.isState);

% Propagate mean indices over sequences to get add indices
d = obj.checkDimensions(dims);
addIndices = cell(1, numel(d));
for k = 1:numel(d)
    addIndices{k} = obj.addIndices(d(k));
    
    % Note if size or mean dimensions change for sequences
    if obj.stateSize(d(k))>1
        siz = [siz(1:d(k)-1), obj.meanSize(d(k)), obj.stateSize(d(k)), siz(d(k)+1:end)];
        meanDims(d(k)+1:end) = meanDims(d(k)+1:end)+1;
    end
end

%% Load individual ensemble members

% Test that a single ensemble member can fit in memory before processing.
% Determine if writing to file or returning output
preSize = obj.stateSize;
preSize(~obj.isState) = preSize(~obj.isState) .* obj.meanSize(~obj.isState);
[~, tooBig] = preallocateEnsemble( prod(preSize), 1);
if tooBig
    tooBigError(obj);
end
writeFile = ~isempty(ens);

% Preallocate as much of the ensemble as fits in memory. Use as many
% ensemble members (chunk size) as possible (within an order of magnitude)
% to limit the number of matfile write operations.
nState = prod(obj.stateSize);
nEns = size(subMembers, 1);
tooBig = true;
nChunk = nEns*10;
while tooBig
    if nChunk == 1   % This should never happen because we tested preSize
        tooBigError(obj);
    end
    nChunk = ceil(nChunk/10);
    [X, tooBig] = preallocateEnsemble(nState, nChunk);
end

% If writing to file, determine columns and track NaN members
if writeFile
    nCols = size(ens, 'X', 2); %#ok<GTARG>
    lastPrevious = nCols - nEns;
    hasnan = false(1, nEns);
end

% Initialize progress bar
if showprogress
    waitname = sprintf('Building "%s":', obj.name);
    waitpercent = ' 0%';
    step = ceil(nEns/100);
    f = waitbar(0, strcat(waitname, waitpercent));
end

% Get load indices for each ensemble member
for m = 1:nEns
    for k = 1:numel(d)
        indices{d(k)} = obj.indices{d(k)}(subMembers(m,k)) + addIndices{k};
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
    
    % Add the vector to the ensemble chunk
    k = mod(m, nChunk);
    k(k==0) = nChunk;
    X(:,k) = Xm(:);
    
    % If saving, write complete chunks to file. Record NaN members
    if writeFile && (k==nChunk || m==nEns)
        cols = m-k+1:m;
        ens.X(svRows, lastPrevious+cols) = X(:,1:k);
        hasnan(cols) = any(isnan(X(:,1:k)), 1);
    end
    
    % Optionally display progress bar
    if showprogress && mod(m,step)==0
        waitpercent = sprintf(' %.f%%', m/nEns*100);
        waitbar(m/nEns, f, strcat(waitname, waitpercent));
    end
end
if showprogress
    delete(f);
end

% Set the output
if writeFile
    out = hasnan;
else
    out = X;
end

end

% Error message, helper function
function[] = tooBigError(obj)
error(['The "%s" variable has so many state elements that even a single ',...
    'ensemble member cannot fit in memory. Consider reducing the size of ',...
    '"%s".'], obj.name, obj.name);
end
function[X, tooBig] = preallocateEnsemble(nState, nEns)
%% Attempts to preallocate an ensemble. Returns the ensemble and a scalar
% logical indicating whether the ensemble fits in memory.
%
% [X, tooBig] = preallocateEnsemble(nState, nEns)

tooBig = false;
try
    X = NaN(nState, nEns);
catch
    X = [];
    tooBig = true;
end

end