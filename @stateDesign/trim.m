function[obj] = trim( obj )
%% Trims ensemble dimensions to only allow complete sequences

% Get the ensemble dimensions for each variable
for v = 1:numel( obj.var )    
    var = obj.var(v);
    ensDims = find( ~var.isState );
    
    % And remove any indices for which a full sequence would surpass the
    % length of the dimension
    for dim = 1:numel(ensDims)
        d = ensDims(dim);
        
        dimLength = var.dimSize(d);
        seqLength = max(var.seqDex{d}) + max(var.meanDex{d});
        
        remove = var.indices{d} > dimLength - seqLength;
        obj.var(v).indices{d}(remove) = [];
    end
end

end