function[colnan] = getVarEnsemble(fEns, var, varDex, nEns)
% getVarEnsemble( fEns, var, varDex, nEns )

% Get a read-only matfile object for the gridded data
fGrid = matfile( var.file );

% Get the size of the ensemble dimensions
[ensSize] = getVarSize( var, 'ensOnly', 'seq' );

% Get the total number of sequence elements and elements per sequence
nSeq = prod( ensSize );
nEls = numel(varDex) / nSeq;

% Get N-dimensional subscripted sequence indices
seqDex = subdim( ensSize, (1:nSeq)' );

% Get the reference loading indices and the indices to keep for each chunk
% of loaded data.
[refLoad, keep] = getLoadingIndices( var );

% Writing matfile objects has a high overhead, so we want to minimize the
% number of time we actually write values to the .ens file.

% Determine the most efficient way to build (based on available memory). 
% Preallocate M.
[M, full] = preallocateVarEnsemble( numel(varDex), nSeq, nEns, var.name );

% If we can store full sets of ensemble members, cycle through sequences
if full
    colnan = buildOrderSeqEns( fEns, fGrid, M, var, varDex, seqDex, refLoad, keep, nEns, nSeq, nEls );
    
% If we can only store single ensemble members, cycle through ensemble members
else
    colnan = buildOrderEnsSeq( fEns, fGrid, M, var, varDex, seqDex, refLoad, keep, nEns, nSeq, nEls );
end

end