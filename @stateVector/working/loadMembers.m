function[X] = buildMembers(obj, subMembers, grid, source, params, precision)
%% dash.stateVectorVariable.buildMembers  Build ensemble members for a state vector variable
% ----------
%
%   Inputs:
%       subMembers (matrix, positive integers [nMembers x nEnsDims]): The
%           dimensionally-subscripted ensemble members that should be built
%       grid (scalar gridfile object): The gridfile object for the variable
%       source (

%% Setup

% Get sizes
nDims = numel(obj.dims);
[nMembers, nEnsDims] = size(subMembers);

% Preallocate
nState = prod(obj.stateSize);
X = NaN(nState, nMembers);

% Note whether all members were loaded at once 
allLoaded = false;

% Determine size of loaded data set, and note mean dimensions
loadedSize = obj.stateSize .* obj.meanSize;
meanDims = 1:nDims;
for d = 1:nDims

    % If a dimension has a sequence, split the mean and sequence elements.
    % Update the loaded size and increment the location of mean dimensions
    if ~obj.isState(d) && obj.stateSize(d)>1
        loadedSize = [loadedSize(1:d-1), obj.meanSize(d), obj.stateSize(d), loadedSize(d+1:end)];
        meanDims(d+1:end) = meanDims(d+1:end)+1;
    end
end

% Permute weights for singleton expansion
% ...

% Get NaN flags
% ...

% Preallocate
% ...


%% Pre-load data

% Extract data from pre-loaded dataset
if source.isloaded
    limits = params.limits - source.limits(:,1) + 1;
    indices = dash.indices.fromLimits(limits);
    Xall = source.data(indices{:});
    allLoaded = true;

% Attempt to load all members
elseif params.loadAllMembers
    indices = dash.indices.fromLimits(params.limits);
    try
        s = params.sourceIndices;
        use = ismember(source.indices, s);
        dataSources = source.dataSources(use);

        Xall = grid.loadInternal([], indices, s, dataSources, precision);
        allLoaded = true;
    catch
    end
end


%% Isolate ensemble members

% Process each ensemble member. Initialize state indices for each member.
% Cycle through ensemble dimensions
indices = repmat({':'}, [1, nDims]);
for m = 1:nMembers

    % Get gridfile indices for each ensemble dimension
    for k = 1:nEnsDims
        d = coupling.dims(k);
        referenceIndex = obj.indices{d}(subMembers(m,k));
        indices{d} = referenceIndex + params.addIndices{qqq};

        % Adjust indices if the full spanning set is already loaded
        if allLoaded
            indices{d} = indices{d} - limits(qqq,1) + 1;
        end
    end

    % Extract the data for the ensemble member
    if allLoaded
        Xm = Xall(indices{:});

    % Load the data for the ensemble member
    else
        s = grid.sourcesForLoad(indices);
        use = ismember(source.indices, s);
        dataSources = source.dataSources(use);
        Xm = grid.loadInternal([], indices, s, dataSources, precision);
    end

    % Separate means from sequences
    Xm = reshape(Xm, loadedSize);

    % Take any basic dimensional means
    omitnan = obj.meanType(d)==1 & obj.omitnan(d);
    if any(omitnan)
        Xm = mean(Xm, meanDims(omitnan), 'omitnan');
    end

    includenan = obj.meanType(d)==1 & ~obj.omitnan(d);
    if any(includenan)
        Xm = mean(Xm, meanDims(includenan), 'includenan');
    end

    % Take weighted means.
    for d = 1:nDims
        if obj.meanType(d)==2
            w = obj.weights{d};

            % If omitting NaN, propagate weights over matrix and infill
            if obj.omitnan(d)
                nans = isnan(Xm);
                if any(nans, 'all')
                    w = repmat(w, wSize);
                    w(nans) = NaN;
                end
            end

            % Sum the weights, take the mean
            Xm = sum(w.*Xm, meanDims(d), nanflag(d)) ./ sum(w, meanDims(d), nanflag(d));
        end
    end

    % Convert to state vector and save
    X(:,m) = Xm(:);
end

end
