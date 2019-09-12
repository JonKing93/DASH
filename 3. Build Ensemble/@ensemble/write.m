function[] = write( obj, file )
% Writes an ensemble to a .ens file

% Warn the user about files and stuff...
% ...
% file = file;
% m = matfile(file);
if new
ens.size = [0, 0];
end
%
%

% Preallocate the new values in the matfile
meta = ensembleMetadata( obj.design );
nState = meta.varLimit(end);
nWritten = ens.size(2);
nAdd = meta.nEns - nWritten;
newMembers = ens.size(2)+(1:nAdd);
ens.M( 1:nState, newMembers ) = NaN;

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
            
    % Record NaN members. Write into the .ens file.
    hasnan = any( isnan(M), 1 );
    varIndices = meta.varIndices( var.name );
    ens.M( varIndices, newMembers ) = M;
end

% Update the .ens file
ens.hasnan(newMembers) = hasnan;
ens.ensemble = obj;
ens.complete = true;