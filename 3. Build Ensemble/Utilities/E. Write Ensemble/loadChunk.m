function[sM] = loadChunk( var, seqDex, draw, loadNC, keep )

% Get the ensemble dimension indices
ensDim = find( ~var.isState );

% For each ensemble dimension.
for dim = 1:numel(ensDim)
    
    % Get the dimension index of the dimension
    d = ensDim(dim);
    
    % Get the ensemble index associated with the draw
    ensDex = var.drawDex{d}(draw);
    
    % Get the start index for each load
    loadNC(1,d) = var.indices{d}(ensDex) + var.seqDex{d}(seqDex(dim)) + min(var.meanDex{d});
end

% Load the data
sM = ncread( var.file, 'gridData', loadNC(1,:), loadNC(2,:), loadNC(3,:) );

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
