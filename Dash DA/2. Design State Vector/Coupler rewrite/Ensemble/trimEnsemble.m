function[trimDex] = trimEnsemble( var, dim, index, seq, mean )
%
% Can leave seq and mean unspecified to ull from variable

% Get the dimension index
d = checkVarDim(var, dim);

% Get the data size
[~,~,dimSize] = metaGridfile( var.file );
dimSize = dimSize(d);

% Get the sequence size
seqSize = max(seq) + max(mean);

% Get the indices that are too large
trimDex = (index > dimSize - seqSize); 
end
