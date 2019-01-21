function[design] = ensDimension( design, var, dim, index, seq, mean, nanflag, ensMeta, overlap )
%% Edits an ensemble dimension.

% Setup the edit. Get the template variable, metadata, indices, and coupled
% variables.
[v, index, coupled] = setupEdit( design, var, dim, index, 'ens');

% Check that overlap is a scalar logical
if ~islogical(overlap) || ~isscalar(overlap)
    error('overlap must be a scalar logical.');
end

% Set the values in the variable
design.var(v) = setEnsembleIndices( design.var(v), dim, index, seq, mean, nanflag, ensMeta, overlap );

% For each coupled variable
for k = 1:numel(coupled)
    
    % Get the variable
    Y = design.var(coupled(k));
    
    % Get any synced ensemble properties
    [seq, mean, nanflag, ensMeta] = getSyncedProperties( Y, design.var(v), dim, ...
             design.syncSeq(v,coupled(k)), design.syncMean(v,coupled(k)) );
         
    % Get the dimensional index
    d = checkVarDim( Y, dim );
         
    % Set the properties
    design.var(coupled(k)) = setEnsembleIndices( Y, dim, Y.indices{d}, ...
                                    seq, mean, nanflag, ensMeta, overlap );
end

end