function[var] = trimEnsembleDims( var )
%% Trims ensemble indices to only allow complete sequences.
%
% var: varDesign
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the ensemble dimensions
ensDex = find( ~var.isState );

% For each ensemble dimension
for dim = 1:numel(ensDex)
    d = ensDex(dim);

    % Get the dimension size
    dimSize = var.dimSize(d);

    % Get the sequence size
    seqSize = max(var.seqDex{d}) + max(var.meanDex{d});

    % Get the indices that are too large
    trimDex = (var.indices{d} > dimSize - seqSize); 

    % Remove from indices
    var.indices{d}(trimDex) = [];
end

end
