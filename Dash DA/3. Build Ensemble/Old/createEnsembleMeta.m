function[meta] = createEnsembleMeta( design, nState )
%% This creates a metadata container for an ensemble

% Preallocate the set of all dimensions
allDim = {'var'};

% Add the dimension IDs from each variable
for v = 1:numel(design.var)
    allDim = [allDim, design.var(v).dimID(fixed)]; %#ok<AGROW>
end

% Get the unique dimensions
allDim = unique( allDim );
nDim = numel(allDim);

% Get a metadata placeholder
meta = repmat( {NaN}, nDim, 1 );

% Get the inputs for the metadata structure
stateMeta = cell( nDim*2, 1);
stateMeta(1:2:end) = allDim;
stateMeta(2:2:end) = meta;

% Create the metadata structure
meta = struct( stateMeta{:} );

% Get a cell for the metadata for each state variable
for d = 1:nDim
    meta.(allDim{d}) = cell( nState, 1 );
end

end