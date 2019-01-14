function[design] = coupleVariables(design, X, Y, varargin)

% Parse the synced variable inputs
[syncState, syncSeq, syncMean] = parseInputs( varargin, {'nostate','noseq','nomean'}, {true, true, true}, {'b','b','b'} );

% Get the variables
xv = checkDesignVar(design, X);
X = design.var(xv);

yv = checkDesignVar(design, Y);
Y = design.var(yv);

% Get the X metadata
xmeta = metaGridfile(X.file);

% For each dimension of X
for d = 1:numel(X.dimID)
    
    % If a state dimension and need to sync state dimensions.
    if X.isState(d) && syncState
        
        % Get the state indices for Y
        index = getCoupledStateIndex( Y, X.dimID{d}, xmeta.(X.dimID{d})(X.indices{d}) );
        takeMean = X.takeMean(d);
        nanflag = X.nanflag{d};
        
        % Set the state indices
        design = stateDimension( design, Y.name, X.dimID{d}, index, takeMean, nanflag );
    
    % If an ensemble dimension
    else
        
        % Get the ensemble indices
        index = getCoupledEnsIndex( Y, X.dimID{d}, xmeta.(X.dimID{d})(X.indices{d}) );
        
        % Get synced ensemble properties
        [seq, mean, nanflag] = getSyncedProperties( X, Y, X.dimID{d}, syncSeq, syncMean );
        
        % Set the ensemble indices
        design = ensDimension( design, Y.name, X.dimID{d}, index, seq, mean, nanflag, X.ensMeta{d} );
    end
end

% Mark the variables as coupled
design = markCoupled( design, xv, yv, syncState, syncSeq, syncMean );
end