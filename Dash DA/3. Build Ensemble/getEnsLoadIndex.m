function[ic] = getEnsLoadIndex( var, ic, m, s )
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
    
    % Assign the indices
    ic{ensDim(d)} = var.indices{ensDim(d)}(m) + var.seqDex{ensDim(d)}(s) + var.meanDex{ensDim(d)};
end

end