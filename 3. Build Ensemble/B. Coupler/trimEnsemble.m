function[var] = trimEnsemble( var, dim )
%% Trims ensemble indices to only allow complete sequences.
%
% var: varDesign
%
% dim: Dimension name
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the dimension index
d = checkVarDim(var, dim);

% Get the data size
dimSize = var.dimSize(d);

% Get the sequence size
seqSize = max(var.seqDex{d}) + max(var.meanDex{d});

% Get the indices that are too large
trimDex = (var.indices{d} > dimSize - seqSize); 

% Remove from indices
var.indices{d}(trimDex) = [];
end
