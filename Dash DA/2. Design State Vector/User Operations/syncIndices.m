function[design] = syncIndices( design, vars, template, varargin )
%% Synces the state, sequence, and/or mean indices of variables in a state 
% vector design. If sequence and mean indices are synced and the synced
% variable lacks metadata for the ensemble dimensions, copies the ensMeta
% field from the template variable.

% Parse the inputs
[state, seq, mean, nowarn, nocopy] = parseInputs( varargin, {'state','seq','mean','nowarn','nocopy'}, {false, false, false, false, false}, {'b','b','b','b','b'} );

% Get the template variable and synced variables
xv = checkDesignVar( design, template );
X = design.var(xv);

yv = checkDesignVar(design, vars);
Y = design.var(yv);

% For each sync variable
for v = 1:numel(Y)
    
    % An alarm to notify the user if metadata is being copied.
    notify = sprintf('Variable %s: \n', Y(v).name);
    
    % For each template dimension
    for d = 1:numel(X.dimID)
        
        % If a state dimension and syncing state indices
        if state && X.isState(d)
            
            % Get the indices with matching metadata
            index = getMatchingMetaDex( Y(v), X.dimID{d}, X.meta.(X.dimID{d})(X.indices{d}) );
            takeMean = X.takeMean(d);
            nanflag = X.nanflag{d};
            
            % Set the state indices
            design = stateDimension( design, Y(v).name, X.dimID{d}, index, takeMean, nanflag ); 
            
            % Mark as coupled
            design = markSynced( design, v, 'syncState', nowarn );
        
        % If an ensemble dimension and syncing seq or mean
        elseif (seq || mean) && ~X.isState(d)
         
            % Get synced ensemble properties
            [seqDex, meanDex, nanflag] = getSyncedProperties( X, Y(v), X.dimID{d}, seq, mean );
        
            % Set synced ensemble properties
            design = ensDimension( design, Y(v).name, X.dimID{d}, [], seqDex, meanDex, nanflag, X.ensMeta{d} );
            
            % Mark as synced
            if seq
                design = markSynced( design, v, 'syncSeq', nowarn);
            end
            if mean
                design = markSynced( design, v, 'syncMean', nowarn );
            end
            
            % Copy metadata if appropriate
            if ~nocopy 
                design = checkCopyMeta( design, Y(v).name, X.name, X.dimID{d} );
            end
        end
    end
end

end