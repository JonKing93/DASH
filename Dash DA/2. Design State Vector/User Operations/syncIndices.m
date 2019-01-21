function[design] = syncIndices( design, vars, template, varargin )
%% Synces the state, sequence, and/or mean indices of variables in a state 
% vector design.

% Parse the inputs
[state, seq, mean, nowarn] = parseInputs( varargin, {'state','seq','mean','nowarn'}, {false, false, false, false}, {'b','b','b','b'} );

% Get the template variable and synced variables
xv = checkDesignVar( design, template );
X = design.var(xv);

yv = checkDesignVar(design, vars);
Y = design.var(yv);

% For each template dimension in each variable
for d = 1:numel(X.dimID)
    for v = 1:numel(Y)
        
        % If syncing state
        if state
            
            % Get the indices with matching metadata
            index = getMatchingMetaDex( Y(v), X.dimID{d}, X.meta.(X.dimID{d})(X.indices{d}) );
            takeMean = X.takeMean(d);
            nanflag = X.nanflag{d};
            
            % Set the state indices
            design = stateDimension( design, Y(v).name, X.dimID{d}, index, takeMean, nanflag ); 
        end
        
        % Get synced ensemble properties
        [seqDex, meanDex, nanflag] = getSyncedProperties( X, Y(v), X.dimID{d}, seq, mean );
        
        % Set synced ensemble properties
        design = ensDimension( design, Y(v).name, X.dimID{d}, [], seqDex, meanDex, nanflag, X.ensMeta{d} );
    end
end

% Get the set of all synced vars
v = [xv;yv];

% Mark whatever was synced
if state
    design = markSynced( design, v, 'syncState', nowarn );
end
if seq
    design = markSynced( design, v, 'syncSeq', nowarn);
end
if mean
    design = markSynced( design, v, 'syncMean', nowarn );
end

end