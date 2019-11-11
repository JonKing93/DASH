function[M, passVals] = buildEnsemble( var, nWritten, varSize, nMean, passVals )
% Builds part of a prior for a single variable

% Preallocate the ensemble for the variable
nNew = size(var.drawDex,1) - nWritten;
nState = prod( varSize );
M = NaN( nState, nNew );

% Preallocate scs and keep
nDim = numel(var.dimID);
scs = NaN(3, nDim);
keep = cell(nDim,1);

% Get scs and keep for the state dimensions
stateDim = find( var.isState );
for d = 1:numel(stateDim)
    [scs(:,stateDim(d)), keep{stateDim(d)}] = loadKeep( var.indices{stateDim(d)} );
end

% Get the add indices and unordering for the ensemble dimensions
ensDim = find( ~var.isState );
addIndex = cell( numel(ensDim), 1 );
unorder = repmat( {':'}, [nDim, 1]);
for d = 1:numel(ensDim)
    addIndex{d} = var.seqDex{ensDim(d)}' + var.meanDex{ensDim(d)};
    [addIndex{d}, i] = sort( addIndex{d}(:) );
    [~, unorder{ensDim(d)}] = sort( i );
end

% Get the sequence number associated with each ensemble dimension element.
nSeq = prod( varSize(ensDim) );
nDup = [1, varSize(ensDim)];
nRep = [nMean(ensDim), 1]; 
seq = 1;
k = 1;
for d = 1:numel(nDup)
    kNew = nDup(d) * k;
    addk = repmat( 0:k:kNew-k, [size(seq,1),1] );
    k = kNew;

    seq = repmat( seq, [nDup(d),1] );
    seq = seq + addk(:);
    seq = repmat( seq, [nRep(d),1] );
end

% Get a sequence sorting order and unpermute order for the data reshape
[~, seqOrder] = sort( seq );
seqOrder = [ repmat({':'}, [numel(stateDim),1]); seqOrder ];
[~, unpermute] = sort( [stateDim;ensDim] );
unpermute = [unpermute; max(unpermute)+1];

% Load each ensemble member
progressbar( char(var.name) );
for mc = 1:nNew
    draw = nWritten + mc;
    
    % Get scs and keep for the ensemble dimensions
    for d = 1:numel(ensDim)
        ensMember = var.drawDex(draw, d);
        indices = var.indices{ensDim(d)}(ensMember) + addIndex{d};
        [scs(:,ensDim(d)), keep{ensDim(d)}] = loadKeep( indices );
    end
        
    % Load data, discard unneeded values. Unsort add indices
    [data, passVals] = gridFile.read( var.file, scs, passVals );
    data = data( keep{:} );
    data = data( unorder{:} );
    
    % Reshape sequences along the end+1 dimension
    data = reshape( data, [ varSize(stateDim).*nMean(stateDim),  prod([nMean(ensDim),varSize(ensDim)]) ] );
    data = data( seqOrder{:} );
    data = reshape( data, [varSize(stateDim).*nMean(stateDim), nMean(ensDim), nSeq] );
    data = permute( data, unpermute );
    
    % Take weighted means
    dims = 1:numel(var.dimID);
    for w = 1:numel( var.weights )
        wdim = find( var.weightDims(w,:) );
        data = sum( data.*var.weights{w}, wdim, var.nanflag{wdim(1)} ) ./ sum(var.weights{w}, 'all');
        dims( ismember(dims,wdim) ) = [];
    end
    
    % Take normal means over the remaining dimensions
    for d = 1:numel( dims )
        if var.takeMean(dims(d))
            data = mean( data, dims(d), var.nanflag{dims(d)} );
        end
    end
    
    % Store ensemble member as state vector.
    M(:,mc) = data(:);
    progressbar( mc / nNew );
end

end