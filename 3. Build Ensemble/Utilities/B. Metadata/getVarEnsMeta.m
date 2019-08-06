function[meta] = getVarEnsMeta( var )

% For each dimension
    for d = 1:numel(var.dimID)
        
        % If a state dimension, get the metadata by querying the grid
        % metadata at the state indices
        if var.isState(d)
            dimMeta = var.meta.(var.dimID(d))( var.indices{d}, : );
            
            % If the state dimension is taking a mean, propagate the
            % multiple sets of metadata down the third dimension.
            if var.takeMean(d)
                dimMeta = permute(dimMeta, [3 2 1]);
            end
            
        % Otherwise, if this is an ensemble dimension, the dimensional
        % metadata is the entire set of sequence metadata
        else
            dimMeta = var.seqMeta{d};
        end
        
        % So, we now have the set of metadata restricted to the useful
        % indices for the dimension. Save this to the metadata structure
        meta.(var.dimID(d)) = dimMeta;
    end
end

