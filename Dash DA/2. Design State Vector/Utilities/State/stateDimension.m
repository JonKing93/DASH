function[d] = stateDimension( d, var, dim, index, takeMean, nanflag )

% Setup for the edit. Get indices, metadata, template variable, coupled
% variables.
[v, var, meta, index, coupled, d] = setupEdit( d, var, dim, index, 'state' );

% Restrict the metadata to the state indices
meta = meta(index);

% For each coupled variable
for c = coupled
    
    % Get the state indices
    stateDex = getCoupledStateIndex( d.var(c), dim, meta );
    
    % Set the values
    d.var(c) = setStateIndices( d.var(c), dim, stateDex, takeMean, nanflag );
end

% Set the values template variable
d.var(v) = setStateIndices( var, dim, index, takeMean, nanflag );

end