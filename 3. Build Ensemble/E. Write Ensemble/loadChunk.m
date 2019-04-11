function[sM] = loadChunk( fGrid, var, seqDex, mc, refLoad, keep )

% Initialize a set of load indices for the SPECIFIC ensemble member
load = refLoad;

% Get the ensemble dimension indices
ensDex = find( ~var.isState );

% For each ensemble dimension.
for dim = 1:numel(ensDex)
    
    % Get the dimension index of the dimension
    d = ensDex(dim);
    
    % Get the specific load indices
    load{d} = var.drawDex{d}(mc) + var.seqDex{d}(seqDex(dim)) + refLoad{d};
end

% Load the data
sM = fGrid.gridData( load{:} );

% Only keep the values associated with sampling indices.
sM = sM( keep{:} );

% Take the mean along any dimension with a mean
for d = 1:numel(var.dimID)
    if var.takeMean(d)
        sM = mean( sM, d, var.nanflag{d} );
    end
end

% Convert to state vector
sM = sM(:);

end
