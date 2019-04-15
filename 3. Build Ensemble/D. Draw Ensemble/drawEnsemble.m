function[design] = drawEnsemble( design, nEns, addDraws )

% Get the sets of coupled variables
coupVars = getCoupledVars( design );

% For each set of coupled variables
for cv = 1:numel(coupVars)
    vars = design.var( coupVars{cv} );
    
    % Initialize the number of draws and get the overlap permission
    nDraws = nEns;
    overlap = vars(1).overlap;
        
    % Get the index and size of each ensemble dimension
    [ensSize, ensDim] = getVarSize( vars(1), 'ensOnly', 'ensDex' );
    
    % Get the subscripted sequence elements. (These will be used to check
    % for overlap between draws.) If overlap is permitted, just set to zero
    seqEls = zeros(1,numel(ensDim));
    if ~overlap
        seqEls = subSequenceEls( vars );
    end
    nSeq = size( seqEls, 1 );
    
    % Preallocate the sampling indices. These are the actual grid indices
    % from which climate data will be loaded. They consist of the sequence 
    % elements associated with each specific ensemble index.
    sampDex = NaN( nSeq*nDraws, numel(ensDim) );  
    
    % If this is a new ensemble, initialize the draws that have not yet
    % been selected
    if ~addDraws
        undrawn = (1 : prod(ensSize))';
        
    % But if adding more draws to an existing ensemble.
    else
        
        % Get the sampling indices for the existing ensemble indices
        currEns = cell2mat(  vars(1).drawDex( ensDim )'  );
        currSamp = getSamplingIndices( currEns, seqEls );
        
        % Combine these pre-existing sampling indices with the indices for
        % the new draws (to prevent overlap with existing draws).
        sampDex = [currSamp; sampDex]; %#ok<AGROW>
        
        % Only make draws from values that were not previously selected
        undrawn = vars(1).undrawn;
    end
    
    % Make draws until the ensemble is built, or throw an error if the
    % total number of draws is not possbile.
    while nDraws > 0
        if nDraws > numel(undrawn)
            ensSizeError(nDraws, numel(undrawn));
        end

        % Randomly draw ensemble members
        currDraws = randsample( undrawn, nDraws );

        % Remove these draws from the list of undrawn ensemble members
        undrawn( ismember( undrawn, currDraws) ) = [];

        % Subscript the draws to N-dimensions.
        subDraws = subdim( ensSize, currDraws );
        
        % Previously, ensemble indices were matched (via metadata) for the set
        % of coupled variables. So, the subscripted draws refer to the
        % same ordered set of ensemble indices for all the coupled variables.
        %
        % Note that the subscripted draws refer to ensemble INDICES. They
        % are indexing an index, and not a climate data value. We'll use 
        % these draw indices to check for overlap between the sampling
        % indices associated with all the specific ensemble indices.
        %
        % So, we'll need to get the set of ensemble indices associated with
        % these draw indices, add to the sequence elements, and check
        % for repeated elements in the full set of sampling indices.
        
        % Get the set of ensemble indices associated with the draw indices
        ensDex = NaN( size(subDraws) );
        for d = 1:numel(ensDim)
            ensDex(:,d) = vars(1).indices{ ensDim(d) }( subDraws(:,d) );
        end
        
        % Get the total set of sampling indices (including the new draws)
        sampDex( (end - nDraws*nSeq + 1):end, : ) = getSamplingIndices( ensDex, seqEls );
        
        % Remove any draws associated with overlapping sampling indices.
        sampDex = removeOverlappingDraws( sampDex, nSeq );
        
        % Get the number of draws remaining
        nDraws = sum( isnan(sampDex(:,1)) / nSeq );
    end
        
    % Get the final drawn ensemble indices
    ensDraws = sampDex( 1:nSeq:end, : ) - seqEls(1,:);
    
    % Add the draws to the design
    design.var( coupVars{cv} ) = assignEnsDraws( vars, ensDraws, vars(1).dimID(ensDim), undrawn ); 
end

end

function[] = ensSizeError(nEns, vars, overlap)

oStr = '';
if ~overlap
    oStr = 'non-overlapping ';
end
 
coupled = sprintf('%s, ', vars.name);
error( ['Cannot select %.f %sensemble members for coupled variables %s', ...
        sprintf('\b\b.\nUse a smaller ensemble.')], nEns, oStr, coupled );
end