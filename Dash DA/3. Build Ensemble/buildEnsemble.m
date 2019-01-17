function[M, ensMeta] = buildEnsemble( design, nEns, overlap )
%% Builds an ensemble from a state vector design
%
% [M, meta] = buildEnsemble( design, nEns )
% Builds a state vector ensemble according to a state vector design.
%
% [M, meta] = buildEnsemble( design, nEns, overlap )
% Specifies whether to allow overlapping, non-duplicate ensemble members.


% Set default overlap
if ~exist('overlap','var') || isempty(overlap)
    overlap = false;
end

% Get the set of coupled variables
varSets = getCoupledVars( design );

% Assign the ensemble indices for each set
for s = 1:numel(varSets)
    design.var(varSets{s}) = assignEnsIndices( design.var(varSets{s}), nEns, overlap );
end

% Get the size of a final state vector
[nState, varDex] = getStateVarDex( design );
nState = sum(nState);

% Create the metadata container
ensMeta = createEnsembleMeta( design, nState, varDex );

% Preallocate the ensemble
M = NaN(nState, nEns);

% For each variable
for v = 1:numel(design.var)
    
    % Create an index cell for loading from the gridfile
    nDim = numel(design.var(v).dimID);
    ic = repmat( {}, [1, nDim]);
    
    % Also create an index cell for trimming unequally spaced indices
    ix = repmat( {':'}, [1, nDim]);
    
    % Get the load and trim indices for each dimension
    for d = 1:nDim
        [ic{d}, ix{d}] = getLoadTrimIndex( design.var(v), d );
    end
        
    % Build the ensemble for the variable
    M(varDex{v}, :) = buildVarEnsemble( design.var(v), nEns, ic, ix );
end

end