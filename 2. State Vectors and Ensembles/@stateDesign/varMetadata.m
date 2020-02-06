function[stateMeta, ensMeta] = varMetadata( obj )
% Gets the ensemble metadata for each variable

% Use a structure to store output
stateMeta = struct;
ensMeta = struct;

% Run through each dimension of each variable, reading metadata
nVar = numel(obj.var);
nDim = numel(obj.var(1).dimID);
for v = 1:nVar
    var = obj.var(v);
    ensDim = 1;
    for d = 1:nDim
        
        % For state dimensions, get metadata at state indices. If taking a
        % mean, propagate down the third dimension.
        if var.isState(d)
            dimMeta = var.meta.(var.dimID(d))( var.indices{d}, : );
            if var.takeMean(d)
                dimMeta = permute( dimMeta, [3 2 1] );
            end
            
        % For ensemble dimensions, use the sequence metadata
        else
            dimMeta = var.seqMeta{d};
        end
        stateMeta.(obj.varName(v)).(var.dimID(d)) = dimMeta;
                    
        % Record grid metadata associated with ensemble members.
        if ~isempty( var.drawDex )
            ensMeta.(obj.varName(v)).(var.dimID(d)) = ...
                    var.meta.(var.dimID(d))( var.indices{d}(var.drawDex(:,ensDim)), : );
            ensDim = ensDim + 1;
        end
        
    end
end

end
        