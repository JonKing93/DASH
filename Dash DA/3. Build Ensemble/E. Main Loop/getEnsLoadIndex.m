function[ic] = getEnsLoadIndex( var, ic, subSeq, m )
%% Gets the load indices for ensemble dimensions for a particular sequence
% element of a particular ensemble member.
%
% m: Ensemble member
%
% s: Sequence element

% Get the ensemble dimensions
ensDim = find( ~var.isState );
nDim = numel(ensDim);

% For each dimension
for d = 1:nDim
    
    % Assign the indices. (Recall that iLoad is holding the mean indices)
    ic{ensDim(d)} = var.indices{ensDim(d)}(m) + var.seqDex{ensDim(d)}(subSeq(d)) + ic{ensDim(d)};
end

end