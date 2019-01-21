function[var] = trimEnsemble( var, dim )
%% Trims ensemble indices to only allow complete sequences.

% Get the dimension index
d = checkVarDim(var, dim);

% Get the data size
dimSize = var.dimSize(d);

% Get the sequence size
seqSize = max(var.seqDex{d}) + max(var.meanDex{d});

% Get the indices that are too large
trimDex = (index > dimSize - seqSize); 

% Remove from indices
var.indices{d}(trimDex) = [];
end
