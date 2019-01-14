function[design] = coupleVariables(design, var, template, varargin)

% Parse the synced variable inputs
[syncState, syncSeq, syncMean] = parseInputs( varargin, {'nostate','noseq','nomean'}, {true, true, true}, {'b','b','b'} );

% Get the variables
xv = checkDesignVar(design, template);
template = design.var(xv);

yv = checkDesignVar(design, var);
var = design.var(yv);

% Get the X metadata
xmeta = metaGridfile(template.file);

% For each dimension of X
for d = 1:numel(template.dimID)
    
    % If a state dimension and need to sync state dimensions.
    if template.isState(d) && syncState
        
        % Get the state indices for Y
        index = getCoupledStateIndex( var, template.dimID{d}, xmeta.(template.dimID{d})(template.indices{d}) );
        takeMean = template.takeMean(d);
        nanflag = template.nanflag{d};
        
        % Set the state indices
        design = stateDimension( design, var.name, template.dimID{d}, index, takeMean, nanflag );
    
    % If an ensemble dimension
    else
        
        % Get the ensemble indices
        index = getCoupledEnsIndex( var, template.dimID{d}, xmeta.(template.dimID{d})(template.indices{d}) );
        
        % Get synced ensemble properties
        [seq, mean, nanflag] = getSyncedProperties( template, var, template.dimID{d}, syncSeq, syncMean );
        
        % Set the ensemble indices
        design = ensDimension( design, var.name, template.dimID{d}, index, seq, mean, nanflag, template.ensMeta{d} );
    end
end

% Mark the variables as coupled
design = markCoupled( design, xv, yv, syncState, syncSeq, syncMean );
end