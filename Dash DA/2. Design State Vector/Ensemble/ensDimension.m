function[design] = ensDimension( design, var, dim, index, seq, mean, nanflag, ensMeta )

% Get the variable design
v = checkDesignVar(design, var);
var = design.var(v);

% Get the dimension index
d = checkVarDim(var, dim);

% Check that the indices are allowed and trim to only allow full sequences
checkIndices(var, d, index)

trimDex = trimEnsemble(var, d, index, seq, mean);
index = index(~trimDex);

% Do initial build of template variable
var = setEnsembleIndices( var, dim, index, seq, mean, nanflag, ensMeta );

% Get the metadata for the dimension
meta = metaGridfile( var.file );
meta = meta.(var.dimID{d});

% Get the variables with coupled ensemble indices
coupled = find( design.isCoupled(v,:) );
coupVars = design.var(coupled);

% Preallocate an index array to track overlapping metadata
nCoup = sum(coupled);
ensDex = NaN(numel(index),nCoup+1);
ensDex(:,1) = index;

% Preallocate sequence index, mean index, and nanflag
seqDex = cell(nCoup,1);
meanDex = cell(nCoup,1);
nanDex = cell(nCoup,1);

% Get the ensemble indices for each variable. Trim and propagate through
% the ensemble indices of all coupled variables.
for c = 1:nCoup
    
    % Get the indices with matching metadata
    [iy, ix] = getCoupledEnsIndex( coupVars(c), dim, meta(ensDex(:,1)) );
    
    % Set the values in the index array
    ensDex(ix,c+1) = iy;
    
    % Get synced properties
    syncSeq = design.coupleSeq(v, coupled(c));
    syncMean = design.coupleMean(v, coupled(c));
    [seqDex{c}, meanDex{c}, nanDex{c}] = getSyncedProperties( var, coupVars(c), dim, syncSeq, syncMean );
    
    % Trim the indices to only allow full sequences
    trimDex = trimEnsemble( coupVars(c), dim, iy, seqDex{c}, meanDex{c} );
    ensDex(ix(trimDex),:) = [];
    
    % Remove any non-overlapping values 
    ensDex( isnan(ensDex(:,c+1)), : ) = [];
end

% Check that ensDex is not empty
if isempty(ensDex)
    error('There are no ensemble members that permit full sequences of all coupled variables.');
end

% Indices now overlap ALL coupled variables. Set the indices for each variable.
for c = 1:nCoup   
    coupVars(c) = setEnsembleIndices(coupVars(c), dim, ensDex(:,c+1), seqDex{c}, meanDex{c}, nanDex{c}, ensMeta);
end

% Set the value of the metadata in all coupled variables

% Save the values in the design
design.var(coupled) = coupVars;
design.var(v) = setEnsembleIndices( var, dim, ensDex(:,1), seq, mean, nanflag, ensMeta );

end