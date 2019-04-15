function[design] = drawEnsemble( design, nEns, addDraws )

% Get the sets of coupled variables
coupVars = getCoupledVars( design );

% For each set of coupled variables
for cv = 1:numel(coupVars)
    vars = design.var( coupVars{cv} );
    
    % Get the overlap permission
    overlap = vars(1).overlap;
    
    % Initialize the number of draws needed
    nDraws = nEns;
    
    % Get the index and size of each ensemble dimension
    [ensSize, ensDim] = getVarSize( vars(1), 'ensOnly', 'ensDex' );
    
    % If drawing an initial ensemble, get the total number of possible
    % draws, and index draws that have NOT yet been selected.
    if ~addDraws
        nTot = prod( ensSize );
        undrawn = (1:nTot)';
        
    % If adding to an existing ensemble, get the undrawn values from the
    % state vector design
    else
        undrawn = vars(1).undrawn;
    end

    % Get the subscripted sequence elements. (These will be used to check
    % for overlap between draws.) If overlap is permitted, just set to zero
    seqEls = zeros(1,numel(ensDim));
    if ~overlap
        seqEls = subSequenceEls( vars );
    end
    nSeq = size( seqEls, 1 );
    
    % Preallocate the sampling indices. These are the actual grid indices
    % from which climate data will be loaded.
    sampDex = NaN( nSeq*nDraws, numel(ensDim) );
    
    % If adding to an existing ensemble
    if add
        
        % Get the sampling indices for the existing draws
        currDraw = vars(1).drawDex( ensDim );
        currDraw = cell2mat( currDraw' );
        
        % Replicate over the sequence indices
    
    
    
    
    
    
    % Make draws until either the ensemble is built, or everything has been attempted
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
        % same set of ensemble indices for all the coupled variables.
        %
        % Note that the subscripted draws refer to ensemble INDICES. They
        % are indexing an index, and not a climate data value. This is
        % good, because we want to check if the draw indices will overlap.
        %
        % So, we'll need to get the set of ensemble indices associated with
        % these subscript indices, add in the sequence elements, and check
        % for repeated elements for the full set of sampling indices.
        
        % Preallocate the set of newly drawn ensemble indices
        ensDex = NaN( size(subDraws) );
        
        % Get the set of drawn ensemble indices.
        for d = 1:numel(ensDim)
            ensDex(:,d) = vars(1).indices{ ensDim(d) }( subDraws(:,d) );
        end
         
        % Replicate the sequence elements over each drawn ensemble index
        repSeqEls = repmat( seqEls, [nDraws,1] );
        
        % Replicate the drawn ensemble indices over each sequence element.
        repEnsDex = repmat( ensDex(:)', [nSeq, 1] );
        repEnsDex = reshape( repEnsDex, [nSeq*nDraws, numel(ensDim)] );
        
        % Add together to get the full set of sampling indices associated 
        % with these draws. Add to the set of previous successful draws.
        sampDex( (end - nDraws*nSeq + 1):end, : ) = repEnsDex + repSeqEls;
        
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