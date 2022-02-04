function[X] = buildMembers(obj, dims, subMembers, grid, source, parameters)
%% dash.stateVectorVariable.buildMembers  Builds a set of ensemble members for a state vector variable
% ----------
%   X = obj.buildMembers(dims, subMembers, grid, source, parameters)
%   Builds ensemble members for a variable given a set of
%   dimensionally-subscripted ensemble members. Attempts to load ensemble
%   members data as efficiently as possible. If gridfile data is
%   pre-loaded, extracts ensemble members from the loaded array. If data is
%   not loaded, attempts to load data for all ensemble members
%   simultaneously. As a last resort, loads data for individual ensemble
%   members from the gridfile.
%
%   After data is loaded, reshapes dimensions to split means and sequences.
%   Takes means / weighted means over appropriate dimensions and converts
%   the processed ensemble member to a state vector.
% ----------
%   Inputs:
%       dims (vector, linear indices [nEnsDims]): The dimension indices for
%           the variable that correspond to the columns of subMembers.
%       subMembers (matrix, linear indices [nInitial x nEnsDims]): A set of
%           dimensionally-subscripted ensemble members for the variable.
%       grid (scalar gridfile object): The gridfile object for the variable
%       source (scalar struct): Data source parameters for the gridfile.
%           Output from stateVector.buildEnsemble/gridSources.
%       parameters (scalar struct): Build-parameters for the variable.
%           Created in stateVector.buildEnsemble.
%
%   Outputs:
%       X (numeric matrix): The loaded data array
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.buildMembers')">Documentation Page</a>

%% Preallocate

% Get sizes
[nMembers, nEnsDims] = size(subMembers);
nState = parameters.nState;
nDims = numel(obj.dims);

% Preallocate. Tag error if array is too large
try
    X = NaN(nState, nMembers);
catch
    id = 'DASH:stateVectorVariable:buildMembers:arrayTooBig';
    error(id, '');
end


%% Load all members

% If attempting to load all members, get load indices.
allLoaded = false;
if parameters.loadAllMembers
    indices = obj.indices;
    indices(dims) = dash.indices.fromLimits(parameters.indexLimits);

    % Get dataSources
    s = grid.sourcesForLoad(indices);
    use = ismember(source.indices, s);
    dataSources = source.dataSources(use);

    % Attempt to load data for all members. Note if failed. (Failure could
    % occur if the data for all members is too large for memory).
    allLoaded = true;
    try
        Xall = grid.loadInternal([], indices, s, dataSources);
    catch
        allLoaded = false;
    end
end


%% Setup tasks

% Get the add indices for each ensemble dimension
addIndices = cell(1, nEnsDims);
for k = 1:nEnsDims
    d = dims(k);
    addIndices{k} = obj.addIndices(d);
end

% Identify standard omitnan and includenan dimensions
includenan = obj.meanType==1 & ~obj.omitnan;
includenan = parameters.meanDims(includenan);
omitnan = obj.meanType==1 & obj.omitnan;
omitnan = parameters.meanDims(omitnan);

% Identify weighted omitnan and includenan dimensions
weightinclude = obj.meanType==2 & ~obj.omitnan;
weightinclude = parameters.meanDims(weightinclude);
weightomit = obj.meanType==2 & obj.omitnan;
weightomit = parameters.meanDims(weightomit);

% Initialize parameters for processing weighted means.
weightParameters = cell(1, nDims);
wSize = parameters.rawSize;
wSize(includenan) = 1;
wSize(omitnan) = 1;
wSize(weightinclude) = 1;

% Cycle through dimensions with weighted means
for d = 1:nDims
    if obj.meanType(d)==2
        md = parameters.meanDims(d);

        % If including NaN, get weight sum for denominator
        if ~obj.omitnan(d)
            weightParameters{d} = sum(obj.weights{d}, 'includenan');

        % If omitting NaN, get size for propagating over array. (This will
        % also update weight size for later weighted mean omitnans).
        else
            wSize(md) = 1;
            weightParameters{d} = wSize;
        end

        % Reshape weights for singleton expansion
        nWeights = numel(obj.weights{d});
        siz = [ones(1,md-1), nWeights, 1];
        obj.weights{d} = reshape(obj.weights{d}, siz);
    end
end


%% Extract raw ensemble members

% Initialize load indices. Adjust state indices if all data was loaded.
% (State dimension index limits are used when pre-loading data).
indices = obj.indices;
if source.isloaded
    for d = 1:nDims
        if obj.isState(d)
            indices{d} = indices{d} - parameters.indexLimits(d,1) + 1;
        end
    end
end

% Cycle through ensemble members. Get load indices for each ensemble dimension
for m = 1:nMembers
    for k = 1:nEnsDims
        d = dims(k);
        referenceIndex = obj.indices{d}(subMembers(m,k));
        indices{d} = referenceIndex + addIndices{k};

        % Adjust indices for index limits if pre-loaded or all members
        if source.isloaded
            indices{d} = indices{d} - parameters.indexLimits(d,1) + 1;
        elseif allLoaded
            indices{d} = indices{d} - parameters.indexLimits(k,1) + 1;
        end
    end

    % Extract member from pre-loaded array, or all members array
    if source.isloaded
        Xm = source.data(indices{:});
    elseif allLoaded
        Xm = Xall(indices{:});

    % Or load member from gridfile
    else
        s = grid.sourcesForLoad(indices);
        use = ismember(source.indices, s);
        dataSources = source.dataSources(use);
        Xm = grid.loadInternal([], indices, s, dataSources);
    end


    %% Process ensemble member

    % Separate means from sequences
    Xm = reshape(Xm, parameters.rawSize);

    % *** Notes on means ***
    % 1. Take includenan means before omitnan means (if you took omitnan
    %    first, there would be no NaNs to include)
    % 2. Taking includenan first also helps minimize size of weight
    %    propagation for weighted omitnan means

    % Take standard includenan means
    if ~isempty(includenan)
        Xm = mean(Xm, includenan, "includenan");
    end

    % Take weighted includenan
    for k = 1:numel(weightinclude)
        d = weightinclude(k);
        md = parameters.meanDims(d);
        
        w = obj.weights{d};
        denominator = weightParameters{d};
        Xm = sum(w.*Xm, md, "includenan") ./ denominator;
    end

    % Take standard omitnan
    if ~isempty(omitnan)
        Xm = mean(Xm, omitnan, "omitnan");
    end

    % Take weighted omitnan. Only propagate over array if necessary
    for k = 1:numel(weightomit)
        d = weightomit(k);
        md = parameters.meanDims(d);
        w = obj.weights{d};

        nans = isnan(Xm);
        if any(nans, 'all')
            siz = obj.weightParameters{d};
            w = repmat(w, siz);
            w(nans) = NaN;
        end

        Xm = sum(w.*Xm, md, "omitnan") ./ sum(w, md, "omitnan");
    end

    % Record state vector
    X(:,m) = Xm(:);
end

end