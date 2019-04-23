function[design] = drawEnsemble( design, nEns, newEnsemble )

% Get the sets of coupled variables
coupVars = getCoupledVars( design );

% For each set of coupled variables
for cv = 1:numel(coupVars)
    vars = design.var( coupVars{cv} );
    
    % Initialize the number of draws needed and get the overlap permissino
    nDraws = nEns;
    overlap = vars(1).overlap;
    
    % Get the size and ID of each ensemble dimension
    [ensSize, ensDim] = getVarSize( vars(1), 'ensOnly', 'ensDex' );
    ensID = vars(1).dimID( ensDim );
    
    % If this is a new ensemble, initialize the possible and subscripted draws
    if newEnsemble
        undrawn = (1 : prod(ensSize))';
        subDraws = NaN( nDraws, numel(ensID) );
        
    % But if adding more draws to an existing ensemble.
    else
        
        % Only make draws that were not previously selected
        undrawn = vars(1).undrawn;
        
        % Include the previous draws
        oldDraws = cell2mat( vars(1).drawDex( ensDim )' );
        subDraws = [ oldDraws;  NaN(nDraws, numel(ensID)) ];
    end
    
    % Get initial number and desired total number of draws
    nInit = sum( ~isnan( subDraws(:,1) ) );
    nTot = nInit + nEns;
    
    % Make draws until the ensemble is built, or throw an error if the
    % desired number of draws is not possible.
    while nDraws > 0
        if nDraws > numel(undrawn)
            ensSizeError(nDraws, numel(undrawn));
        end

        % Randomly draw ensemble members
        currDraws = randsample( undrawn, nDraws );

        % Remove these draws from the list of undrawn ensemble members
        undrawn( ismember( undrawn, currDraws) ) = [];

        % Subscript the draws to N-dimensions.
        subDraws( nTot-nDraws+1, : ) = subdim( ensSize, currDraws );
        
        % If not allowing overlap, then for each variable...
        if ~overlap
            for v = 1:numel(vars)
                
                % Remove draws associated with overlap
                subDraws = removeOverlappingDraws( vars(v), subDraws, ensID );
                
                % If all the new draws are removed, quit and redraw
                if sum( ~isnan( subDraws(:,1) ) ) == nInit
                    break;
                end
            end
        end
        
        % Get the number of draws remaining
        nDraws = sum( isnan( subDraws(:,1) ) );
    end
        
    % Add the draws to the design
    design.var( coupVars{cv} ) = setVariableDraws( vars, subDraws, ensID, undrawn );
end

end
                

%% A detailed error message when dash cannot select the desired number of draws.
function[] = ensSizeError(nEns, vars, overlap)

oStr = '';
if ~overlap
    oStr = 'non-overlapping ';
end
 
coupled = sprintf('%s, ', vars.name);
error( ['Cannot select %.f %sensemble members for coupled variables %s', ...
        sprintf('\b\b.\nUse a smaller ensemble.')], nEns, oStr, coupled );
end