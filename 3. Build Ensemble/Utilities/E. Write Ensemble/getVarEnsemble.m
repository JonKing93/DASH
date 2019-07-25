function[colnan] = getVarEnsemble(fEns, var, varDex, nEns)
% getVarEnsemble( fEns, var, varDex, nEns )

% Get the size of the ensemble dimensions
[ensSize] = getVarSize( var, 'ensOnly', 'seq' );

% Get the total number of sequence elements (nSeq) and elements per
% sequence (nEls)
nTot = varDex(2) - varDex(1) + 1;
nSeq = prod( ensSize );
nEls = nTot / nSeq;

% Get N-dimensional subscripted sequence indices
seqDex = subdim( ensSize, (1:nSeq)' );

% Get the reference loading indices and the indices to keep for each chunk
% of loaded data.
[loadNC, keep] = getLoadingIndices( var );

% Our ensemble members could be very big or very small. If they are very
% very large, we will need to build the .ens file slightly differently to
% conserve system memory. Also, calling matfile has a high overhead.

% Determine the most efficient way to build (based on available memory). 
% Preallocate M.
[M, full] = preallocateVarEnsemble( nTot, nSeq, nEns, var.name );

% Get the full set of variable indices
varDex = (varDex(1):varDex(end))';

% If we can store full sets of ensemble members, cycle through sequences
if full
    colnan = buildOrderSeqEns( fEns, M, var, varDex, seqDex, loadNC, keep, nEns, nSeq, nEls );
    
% If we can only store single ensemble members, cycle through ensemble members
else
    colnan = buildOrderEnsSeq( fEns, M, var, varDex, seqDex, loadNC, keep, nEns, nSeq, nEls );
end

end