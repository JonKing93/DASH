function[] = write( obj, file, random, writenan, overwrite )
% Writes the ensemble to file.

% Get the matfile. Delete if overwriting
if exist( 'file', 'file' ) && overwrite
    delete(file);
end
ens = matfile( file );

% Preallocate / add initial values into the matfile
ens.complete = false;
ensSize = obj.ensembleSize;
ens.M( 1:ensSize(1), 1:ensSize(2) ) = NaN;
ens.ensSize = ensSize;
ens.random = random;
ens.writenan = writenan;
hasnan = false( 1, ensSize(2) );

% Get information about variable indices and read indices
[start, count, stride, keep] = obj.design.loadingIndices;

% Preallocate the part of the ensemble for each variable.
for v = 1:nVar
    var = obj.design.var(v);
    nState = prod( meta.varSize(v,:) );
    M = NaN( nState, nAdd );
    
    % Get the number of sequences and elements per sequence. Subscript 
    % each element of the sequence to ND
    ensDim = find( ~var.isState );
    nSeq = prod( meta.varSize(v, ensDim) );
    nEls = nState / nSeq;
    subSequence = subdim( (1:nSeq)', meta.varSize(v,ensDim) );

    % Load the sequence for each ensemble member
    for s = 1:nSeq
        varSegment = (s-1)*nEls + (1:nEls)';
        for mc = 1:nAdd
            
            % Get the starting index for ensemble dimensions.
            draw = nWritten + mc;
            for dim = 1:numel(ensDim)
                d = ensDim(dim);
                ensMember = var.drawDex{d}(draw);                
                start(v,d) = var.indices{d}( ensMember ) + var.seqDex{d}( subSequence(s,dim) ) + min( var.meanDex{d} );
            end
            
            % Load the data, discard unneeded values. Take any means.
            data = ncread( var.file, 'gridData', start(v,:), count(v,:), stride(v,:) );
            data = data( keep{v,:} );
            
            for d = 1:numel(var.dimID)
                if var.takeMean(d)
                    data = mean( data, d, var.nanflag{d} );
                end
            end        
            
            % Store as state vector in the workspace ensemble
            M( varSegment, mc ) = data(:);
        end
    end

    % Record NaN members. Write the variable into the .ens file
    hasnan = hasnan | any( isnan(M), 1 );
    varIndices = meta.varIndices( var.name );
    ens.M( varIndices, : ) = M;
end

% Finish adding values to the .ens file
ens.hasnan = hasnan;
obj.new = false;
ens.design = obj;
ens.complete = true;

end