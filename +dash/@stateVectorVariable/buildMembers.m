function[X] = buildMembers(obj, dims, subMembers, grid, source, parameters, precision)
%% dash.stateVectorVariable.buildMembers  Builds a set of ensemble members for a state vector variable
% ----------
%   X = <strong>obj.buildMembers</strong>(dims, subMembers, grid, source, parameters)
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
%           .isloaded (scalar logical): Whether all the data for the variable is loaded
%           .data (numeric array | []): Loaded data for the variable
%           .limits (matrix, positive integers [nDims x 2]): The index
%               limits of the loaded data within the overall gridfile.
%           .dataSources (cell vector [nBuilt]): Successfully built
%               dataSource objects for the gridfile
%           .indices (vector, linear indices [nBuilt]): The indices of the
%               built dataSource objects within the full set of gridfile sources
%       parameters (scalar struct): Build-parameters for the variable.
%           Created in stateVector.buildEnsemble
%           .rawSize (vector, positive integers): The size of a raw ensemble
%               member. This is the size of the ensemble member before any
%               means are taken. Mean and sequence elements are separated
%               from one another.
%           .meanDims (vector, linear index): The index of the dimension
%               containing mean elements in the raw ensemble member.
%               (Because mean and sequence elements are separated from one
%               another, variable dimensions may actually span 2 dimensions
%               of the loaded ensemble member).
%           .nState (scalar positive integer): The number of state vector
%               elements in the final ensemble member
%           .indexLimits (cell vector [nVariables] {index limits [nDims x 2]}):
%               The index limits along each gridfile dimension required to load
%               all ensemble members for a variable.
%           .loadAllMembers (logical vector [nVariables]): Whether each variable
%               has the data sources necessary to load all members at once.
%               Note that this does not guarantee that a variable *actually
%               will* load all members at once, only that a variable should
%               attempt the load.
%           .whichSet (scalar, linear index): The index of the coupling
%               set to which the variable belongs
%           .dims (vector, linear indices [nDimensions]): The indices
%               of the ensemble dimensions in the variable
%       precision ('single' | 'double'): The numerical precision of the
%           output data array
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
    X = NaN(nState, nMembers, precision);
catch
    id = 'DASH:stateVectorVariable:buildMembers:arrayTooBig';
    error(id, 'The state vector ensemble for the variable is too large for active memory.');
end


%% Load all members

% Attempt to load all members
allLoaded = false;
if ~source.isloaded && parameters.loadAllMembers

    % Get load indices. Directly load state indices (no need to span
    % indices because can load directly). Use span over ensemble indices
    indices = obj.indices;
    indices(dims) = dash.indices.fromLimits(parameters.indexLimits);

    % Get dataSources
    s = grid.sourcesForLoad(indices);
    use = ismember(source.indices, s);
    dataSources = source.dataSources(use);

    % Attempt to load data for all members. (Failure could still
    % occur if the data for all members is too large for memory).
    try
        Xall = grid.loadInternal([], indices, s, dataSources);
        allLoaded = true;
    catch
    end
end


%% Setup tasks for means and totals

% Identify standard omitnan and includenan dimensions
standardMean = obj.meanType==1;
meanInclude = standardMean & ~obj.omitnan;
meanOmit = standardMean & obj.omitnan;

standardTotal = obj.meanType==3;
totalInclude = standardTotal & ~obj.omitnan;
totalOmit = standardTotal & obj.omitnan;

% Identify weighted omitnan and includenan dimensions
weightedMean = obj.meanType==2;
weightMeanInclude = weightedMean & ~obj.omitnan;
weightMeanOmit = weightedMean & obj.omitnan;

weightedTotal = obj.meanType==4;
weightTotalInclude = weightedTotal & ~obj.omitnan;
weightTotalOmit = weightedTotal & obj.omitnan;

% Locate dimensions in raw loaded data array
meanInclude = parameters.meanDims(meanInclude);
meanOmit = parameters.meanDims(meanOmit);
totalInclude = parameters.meanDims(totalInclude);
totalOmit = parameters.meanDims(totalOmit);

weightMeanInclude = parameters.meanDims(weightMeanInclude);
weightMeanOmit = parameters.meanDims(weightMeanOmit);
weightTotalInclude = parameters.meanDims(weightTotalInclude);
weightTotalOmit = parameters.meanDims(weightTotalOmit);

% Initialize parameters for weighted means and totals
weightParameters = cell(1, nDims);
wSize = parameters.rawSize;
broadcastWeights = [meanInclude, totalInclude, meanOmit, totalOmit, weightMeanInclude, weightTotalInclude];
wSize(broadcastWeights) = 1;

% Cycle through dimensions with a weighted total or mean
for d = 1:nDims
    if obj.meanType(d)==2 || obj.meanType(d)==4
        md = parameters.meanDims(d);

        % If including NaN, get weight sum for denominator
        if ~obj.omitnan(d)
            weightParameters{d} = sum(obj.weights{d}, 'includenan');

        % If omitting NaN, get size for propagating over array. (This will
        % also update weight size for later weighted omitnans).
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


%% Prepare the load indices

% Get the add indices for each ensemble dimension
addIndices = cell(1, nEnsDims);
for k = 1:nEnsDims
    d = dims(k);
    addIndices{k} = obj.addIndices(d);
end

% Initialize load indices
indices = obj.indices;

% If data was pre-loaded (distinct from the "load-all-members" case), then
% state dimension data is a span. Adjust the state dimension indices
if source.isloaded
    for d = 1:nDims
        if obj.isState(d)
            indices{d} = indices{d} - source.limits(d,1) + 1;
        end
    end

% If all members were loaded, then use the loaded indices directly
elseif allLoaded
    indices(obj.isState) = {':'};
end


%% Extract raw ensemble members

% Cycle through ensemble members. Get load indices for each ensemble dimension
for m = 1:nMembers
    for k = 1:nEnsDims
        d = dims(k);
        referenceIndex = obj.indices{d}(subMembers(m,k));
        indices{d} = referenceIndex + addIndices{k};

        % Adjust indices for index limits if pre-loaded or all members
        if source.isloaded
            indices{d} = indices{d} - source.limits(d,1) + 1;
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

    % Separate means from sequences. (Include trailing 1 in new size in
    % case of scalars or a single dimension).
    Xm = reshape(Xm, [parameters.rawSize, 1]);

    % *** Notes on means ***
    % 1. Take includenan means/totals before omitnan (if you took omitnan
    %    first, there would be no NaNs to include)
    % 2. Taking includenan first also helps minimize size of weight
    %    propagation for weighted omitnan

    % Take standard includenans
    if ~isempty(meanInclude)
        Xm = mean(Xm, meanInclude, "includenan");
    end
    if ~isempty(totalInclude)
        Xm = sum(Xm, totalInclude, "includenan");
    end

    % Weighted includenans
    weightInclude = [weightMeanInclude, weightTotalInclude];
    for k = 1:numel(weightInclude)
        d = weightInclude(k);
        md = parameters.meanDims(d);

        % Weighted sum
        w = obj.weights{d};
        Xm = sum(w.*Xm, md, "includenan");

        % Weighted mean: divide by denominator
        if ismember(d, weightMeanInclude)
            denominator = weightParameters{d};
            Xm = Xm ./ denominator;
        end
    end

    % Standard omitnans
    if ~isempty(meanOmit)
        Xm = mean(Xm, meanOmit, "omitnan");
    end
    if ~isempty(totalOmit)
        Xm = sum(Xm, totalOmit, "omitnan");
    end

    % Weighted omitnan.
    weightOmit = [weightMeanOmit, weightTotalOmit];
    for k = 1:numel(weightOmit)
        d = weightOmit(k);
        md = parameters.meanDims(d);
        w = obj.weights{d};

        % Only propagate weights over array if required for NaN elements
        nans = isnan(Xm);
        if any(nans, 'all')
            siz = weightParameters{d};
            w = repmat(w, siz);
            w(nans) = NaN;
        end

        % Weighted sum or mean
        Xm = sum(w.*Xm, md, "omitnan");
        if ismember(d, weightMeanOmit)
            Xm = Xm ./ sum(w, md, "omitnan");
        end
    end

    % Record state vector
    X(:,m) = Xm(:);
end

end