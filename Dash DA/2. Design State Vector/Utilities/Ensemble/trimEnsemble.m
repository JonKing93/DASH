function[trimDex] = trimEnsemble( var, dim, index, seq, mean )
%% Trims ensemble indices to only allow complete sequences.

% Get the dimension index
d = checkVarDim(var, dim);

% Get the data size
dimSize = var.dimSize(d);

% Get the sequence size
seqSize = max(seq) + max(mean);

% Get the indices that are too large
trimDex = (index > dimSize - seqSize); 
end
