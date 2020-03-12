function[obj] = matchMetadata( obj, cv )
%% Restricts ensemble indices of coupled variables to matching metadata.

% Get the first variable and ensemble dimensions
var1 = obj.var( cv(1) );
ensDim = var1.dimID( ~var1.isState );
ensIndex = find( ~var1.isState );
nVar = numel(cv);

% For each ensemble dimension, run through the set of variables and remove
% any non-intersecting metadata
for dim = 1:numel(ensDim)    
    d = ensIndex(dim);
    meta = var1.meta.(ensDim(dim))( var1.indices{d}, : );
    
    for v = 2:nVar
        var = obj.var( cv(v) );
        varMeta = var.meta.(ensDim(dim))(var.indices{d}, :);
        meta = intersect( meta, varMeta, 'rows', 'stable' );   
    end
    
    % Throw an error if no metadata remains
    if isempty(meta)
        overlapError(obj, cv, ensDim(dim));
    end
    
    % Now we have the metadata intersect. Run through each variable and
    % remove ensemble indices that are not in this intersect.
    for v = 1:nVar
        var = obj.var( cv(v) );
        varMeta = var.meta.(ensDim(dim))(var.indices{d}, :);
        [~, keep] = intersect( varMeta, meta, 'rows', 'stable' );
        obj.var( cv(v) ).indices{d} = var.indices{d}(keep);
    end
end

end

% A fancy error message.
function[] = overlapError(design, cv, dim)

coupled = sprintf('%s, ', design.var(cv).name);
error( ['The ensemble indices of the %s dimension of coupled variables: %s', ...
        'have no overlapping metadata.', newline, ...
        'Check that the ensemble indices point to the same values, and that the .grid metadata is in a common format.'], ...
        dim, coupled );
end