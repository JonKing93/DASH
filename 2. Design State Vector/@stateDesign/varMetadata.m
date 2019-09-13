function[meta] = varMetadata( obj )

% Use a structure to store output
meta = struct;

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
            
        % For state dimensions, use the sequence metadata
        else
            dimMeta = var.seqMeta{d};
        end
        
        % Store in the metadata structure
        meta.(obj.varName(v)).(dimID(d)) = dimMeta;
    end
end

end
        