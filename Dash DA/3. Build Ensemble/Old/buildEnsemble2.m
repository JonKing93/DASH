function[M] = buildEnsemble2( nEns, design )
%% This builds the ensemble for each variable in the state vector.

% Get the indices for each variable in the state vector
[varCell, nEls] = getVariableIndices( design );
nState = sum(nEls);
nVar = numel( design.varDesign );

% Preallocate the ensemble
M = NaN( nState, nEns ); 

% Create a metadata container for the ensemble
meta = createEnsembleMeta( design, nState );

% For each variable
for v = 1:nVar
    
    % Get the variable design
    var = design.varDesign(v);
    nDim = numel( var.dimID );
    
    % Get a read-only matfile
    grid = matfile( var.file );
    
    % Get fixed indices
    [ic, ix] = getIndexCell( var.fixDex, var.fixed );
    
    % Get metadata for the fixed indices
    