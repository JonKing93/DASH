function[colNaN] = getVarEnsemble(fEns, var, varDex, nEns)
% buildVarEnsemble( fEns, var, varDex, nEns )

% Get a read-only matfile object for the gridded data
fGrid = matfile( var.file );

% Get the index and size of the ensemble dimensions
[ensSize, ensDex] = getVarSize( var, 'ensOnly', 'seq' );

% Get the total number of sequence elements and number of elements per sequence
nSeq = prod( ensSize );
nEls = numel( varDex ) / nSeq;

% Get N-dimensional subscripted sequence indices
seqDex = subdim( ensSize, (1:nSeq)' );

% Get the reference loading indices and the indices to keep
[refLoad, keep] = getLoadingIndices( var );

% Track the rows with NaN and the columns with NaN
rowNaN = zeros( numel(varDex), 1 );
colNaN = false( 1, nEns );

% Preallocate the output. Use the largest output that does not result in a
% out-of memory error. (Writing to matfile objects has a high overhead, so
% we want to write as much as possible each time.)
[M, full, seq, ens] = preallocateEnsemble( numel(varDex), nSeq, nEns, var.name );

% For each ensemble member
for mc = 1:nEns
    
    % For each sequence element
    for s = 1:nSeq
        
        % Initialize a specific set of sampling indices from the reference indices.
        load = refLoad;
        
        % Get the unique sampling indics for each ensemble dimension
        for dim = 1:numel(ensDex)
            d = ensDex(dim);
            load{d} = var.drawDex{d}(mc) + var.seqDex{d}(seqDex(s,dim)) + refLoad{d};
        end
        
        % Load the data
        sM = fGrid.gridData( load{:} );
        
        % Only keep the values associated with sampling indices.
        sM = sM( keep{:} );
        
        % Take the mean along any relevant dimensions
        sM = takeDimMeans( sM, var.takeMean, var.nanflag );
        
        % Note if there are any NaN rows
        nanDex = (s-1)*nEls + find(isnan(M));
        rowNaN( nanDex ) = rowNaN( nanDex ) + 1;
        
        
        % If there aren't any NaN rows, going to save the values
        if isempty( nanDex )
            
            % Get the state indices for this sequence
            
            % Write the sequence to the appropriate location
            if full   % Writing entire variable
                stateDex = (s-1)*nEls + (1:nEls)';
                M(stateDex, mc) = sM;
            elseif seq  % Writing entire 
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        % If there are NaN values
        if ~isempty(nanDex)
            
            % Mark the ensemble member for deletion
            colNaN( mc ) = true;
            
            % Mark all the following rows as NaN
            stateDex = (s-1)*nEls+1 : nEls*nSeq;
            rowNaN(stateDex) = rowNaN(stateDex) + 1;
            
            % Don't bother loading any more of this ensemble member.
            break;
        
        % But if not, add to the .ens file
        else
            stateDex = (s-1)*nEls + (1:nEls)';
            fEns.M(stateDex, mc ) = M(:);
        end
    end
end

% If any rows are completely NaN, the entire ensemble is invalid
if any( rowNaN == nEns )
    
    % Delete the .ens file
    delete( fEns.Properties.Source );
    
    % Throw error
    nanRowError( rowNaN, var, varDim );
end

end