function[X] = loadEnsemble(obj, subMembers, grid, sources, showprogress)
%% Load the ensemble for a state vector variable

%% Means

% % Get nanflag and fill unspecified meanSize
% nDims = numel(obj.dims);
% nanflag = repmat("includenan", [1 nDims]);
% nanflag(obj.omitnan) = "omitnan";
% 
% % Track the size and location of dimensions for taking means
% obj.meanSize(isnan(obj.meanSize)) = 1;
% siz = obj.stateSize .* obj.meanSize;
% meanDims = 1:nDims;
% 
% % Get the weights for each dimension with a mean
% for k = 1:nDims
%     if obj.takeMean(k)
%         if isempty(obj.weightCell{k})
%             obj.weightCell{k} = ones(obj.meanSize(k), 1);
%         end
%         
%         % Permute for singleton expansion
%         order = 1:max(2, meanDims(k));
%         order(meanDims(k)) = 1;
%         order(1) = meanDims(k);
%         obj.weightCell{k} = permute(obj.weightCell{k}, order);
%     end
% end
% 
% %% Ensemble dimensions: indices and sequences
% 
% % Initialize load indices with state indices.
% indices = cell(1, nDims);
% indices(obj.isState) = obj.indices(obj.isState);
% 
% % Propagate mean indices over sequences to get add indices
% d = obj.checkDimensions(dims);
% addIndices = cell(1, numel(d));
% for k = 1:numel(d)
%     addIndices{k} = obj.addIndices(d(k));
%     
%     % Note if size or mean dimensions change for sequences
%     if obj.stateSize(d(k))>1
%         siz = [siz(1:d(k)-1), obj.meanSize(d(k)), obj.stateSize(d(k)), siz(d(k)+1:end)];
%         meanDims(d(k)+1:end) = meanDims(d(k)+1:end)+1;
%     end
% end

%% Load the ensemble members

% Preallocate
nState = prod(obj.stateSize);
nEns = size(subMembers, 1);
X = NaN(nState, nEns);

% Initialize progress bar
if showprogress
    waitname = sprintf('Building "%s":', obj.name);
    waitpercent = ' 0%';
    step = ceil(nEns/100);
    f = waitbar(0, strcat(waitname, waitpercent));
end

% Get the load indices for each ensemble member
for m = 1:nEns
    for k = 1:numel(d)
        indices{d(k)} = obj.indices{d(k)}(subMembers(m,k)) + addIndices{k};
    end
    
    % Load the data for the ensemble member. Reshape sequences
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
    
    % Add the finished ensemble member to the output array
    X(:,m) = Xm(:);
    
    % Progress bar
    if showprogress && mod(m,step)==0
        waitpercent = sprintf(' %.f%%', m/nEns*100);
        waitbar(m/nEns, f, strcat(waitname, waitpercent));
    end
end
if showprogress
    delete(f);
end

end