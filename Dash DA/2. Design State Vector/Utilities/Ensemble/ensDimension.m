function[d] = ensDimension( d, var, dim, index, seq, mean, nanflag, ensMeta )

% Setup the edit. Get the template variable, metadata, indices, and coupled
% variables.
[v, var, meta, index, coupled, d] = setupEdit( d, var, dim, index, 'ens');

% Trim indices to only allow full sequences
trimDex = trimEnsemble(var, dim, index, seq, mean);
index = index(~trimDex);

% Do initial build of template variable
var = setEnsembleIndices( var, dim, index, seq, mean, nanflag, ensMeta );

% Get the metadata at the indices
meta = meta(index);

% Preallocate an index array to track overlapping metadata
nCoup = numel(coupled);
ensDex = NaN(numel(index),nCoup+1);
ensDex(:,1) = index;

% Preallocate sequence index, mean index, and nanflag
seqDex = cell(nCoup,1);
meanDex = cell(nCoup,1);
nanDex = cell(nCoup,1);

% Get the ensemble indices for each variable. Trim and propagate through
% the ensemble indices of all coupled variables.
for c = 1:nCoup

    % Get the coupled variable index
    vc = coupled(c);
    
    % Get the indices with matching metadata
    [iy, ix] = getCoupledEnsIndex( d.var(vc), dim, meta );
    
    % Set the values in the index array
    ensDex(ix,c+1) = iy;
    
    % Get synced properties
    syncSeq = d.coupleSeq(v, coupled(c));
    syncMean = d.coupleMean(v, coupled(c));
    [seqDex{c}, meanDex{c}, nanDex{c}] = getSyncedProperties( var, d.var(vc), dim, syncSeq, syncMean );
    
    % Trim the indices to only allow full sequences
    trimDex = trimEnsemble( d.var(vc), dim, iy, seqDex{c}, meanDex{c} );
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
    d.var(vc) = setEnsembleIndices(d.var(vc), dim, ensDex(:,c+1), seqDex{c}, meanDex{c}, nanDex{c}, ensMeta);
end

% Set the value for the template variable
d.var(v) = setEnsembleIndices( var, dim, ensDex(:,1), seq, mean, nanflag, ensMeta );

end