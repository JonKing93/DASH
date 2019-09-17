function[stateMeta, ensMeta] = varMetadata( obj )
% Gets the ensemble metadata for each variable

% Use a structure to store output
stateMeta = struct;
ensMeta = struct;

% Run through each dimension of each variable, reading metadata
nVar = numel(obj.var);
nDim = numel(obj.var.dimID);
for v = 1:nVar
    var = obj.var(v);
    for d = 1:nDim
        
        % For state dimensions, get metadata at state indices. If taking a
        % mean, propagate down the third dimension.
        if var.isState(d)
            dimMeta = var.meta.(var.dimID(d))( var.indices{d}, : );
            if var.takeMean(d)
                dimMeta = permute( dimMeta, [3 2 1] );
            end
            
        % For ensemble dimensions, use the sequence metadata. Also, record
        % the grid metadata associated with each ensemble member
        else
            dimMeta = var.seqMeta{d};
            ensMeta.(obj.varName(v)).(var.dimID(d)) = ...
                    var.meta.(var.dimID(d))( var.indices{d}(var.drawDex{d}), : );
        end
        
        % Store in the metadata structure
        stateMeta.(obj.varName(v)).(var.dimID(d)) = dimMeta;
    end
end

end
        