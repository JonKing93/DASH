function[] = write( obj, file, random, writenan, new )
% Writes the ensemble to file.

% Handle pre-existing or non-existing files.
if new && exist(fullfile(pwd,file),'file')
    delete(file);
elseif ~new && ~exist('file','file')
    error('The file "%s" in the ensemble object does not exist. It may have been deleted or removed from the active path.', file);
end

% Get the matfile and fill in values as appropriate
ens = matfile(file,'Writable', true);
ens.complete = false;
ensSize = obj.ensembleSize;
if new
    nNew = ensSize(2);
    nWritten = 0;
    ens.M( 1:ensSize(1), 1:nNew ) = NaN;
    ens.random = random;
    ens.writenan = writenan;
    ens.hasnan = [];
    hasnan = false(1, ensSize(2));
else
    nWritten = ens.ensSize(1,2);
    nNew = ensSize(2) - nWritten;
    ens.M( :, nWritten + (1:nNew) ) = NaN;
    hasnan = false(1, nNew);
end

% Get information about variable indices and read indices
meta = ensembleMetadata( obj );
[start, count, stride, keep] = obj.loadingIndices;

% Preallocate the part of the ensemble for each variable.
for v = 1:numel(obj.var)
    var = obj.var(v);
    nState = prod( meta.varSize(v,:) );
    M = NaN( nState, nNew );
    
    % Get the number of sequences and elements per sequence. Subscript 
    % each element of the sequence to ND
    ensDim = find( ~var.isState );
    nSeq = prod( meta.varSize(v, ensDim) );
    nEls = nState / nSeq;
    subSequence = subdim( (1:nSeq)', meta.varSize(v,ensDim) );

    % Load the sequence for each ensemble member
    for s = 1:nSeq
        varSegment = (s-1)*nEls + (1:nEls)';
        for mc = 1:nNew
            
            % Get the starting index for ensemble dimensions.
            draw = nWritten + mc;
            for dim = 1:numel(ensDim)
                d = ensDim(dim);
                ensMember = var.drawDex(draw, dim);                
                start(v,d) = var.indices{d}( ensMember ) + var.seqDex{d}( subSequence(s,dim) ) + min( var.meanDex{d} );
            end
            
            % Load the data, discard unneeded values.
            data = ncread( var.file, 'gridData', start(v,:), count(v,:), stride(v,:) );
            data = data( keep{v,:} );
            
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
            
            % Store as state vector in the workspace ensemble
            M( varSegment, mc ) = data(:);
        end
    end

    % Record NaN members. Write the variable into the .ens file
    hasnan = hasnan | any( isnan(M), 1 );
    ens.M( meta.varIndices(var.name), nWritten + (1:nNew) ) = M;
end

% Finish adding values to the .ens file
ens.hasnan = [ens.hasnan, hasnan];
ens.ensSize = ensSize;
obj.new = false;
ens.design = obj;
ens.complete = true;

end