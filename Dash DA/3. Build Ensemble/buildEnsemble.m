function[M, ensMeta] = buildEnsemble( design, nEns )
%% Builds an ensemble from a state vector design
%
% [M, meta] = buildEnsemble( design, nEns )
% Builds a state vector ensemble according to a state vector design.
%

%% Coupler

% Do an error check of the design and get all sets of coupled variables
coupleSet = reviewDesign( design );

% Couple the ensemble indices for each set of coupled variables
for c = 1:numel(coupleSet)
    design = coupler( design, coupleSet{c}, nEns );
end

%% Metadata

% Get the size of a final state vector. Get an index for each variable.
[nState, varDex] = getStateVarDex( design );
nState = sum(nState);

% Create the metadata container
ensMeta = createEnsembleMeta( design, nState, varDex );

%% Build

% Preallocate the ensemble
M = NaN(nState, nEns);

% For each variable
for v = 1:numel(design.var)
    
    % Create an index cell for loading from the gridfile
    nDim = numel(design.var(v).dimID);
    iLoad = repmat( {[]}, [1, nDim]);
    
    % Also create an index cell for trimming unequally spaced indices
    iTrim = repmat( {':'}, [1, nDim]);
    
    % Get the load and trim indices for each dimension
    for d = 1:nDim
        [iLoad{d}, iTrim{d}] = getLoadTrimIndex( design.var(v), d );
    end
        
    % Build the ensemble for the variable
    M(varDex{v}, :) = buildVarEnsemble( design.var(v), nEns, iLoad, iTrim );
end

end