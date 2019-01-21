function[d] = stateDimension( d, var, dim, index, takeMean, nanflag )
%% Edits a state dimension.

% Setup for the edit. Get indices, metadata, template variable, coupled
% variables.
[v, var, meta, index, synced, d] = setupEdit( d, var, dim, index, 'state' );

% Restrict the metadata to the state indices
meta = meta(index);

% For each synced variable
for sv = synced
    
    % Get the state indices
    stateDex = getMatchingMetaDex( d.var(sv), dim, meta, true );
    
    % Set the values
    d.var(sv) = setStateIndices( d.var(sv), dim, stateDex, takeMean, nanflag );
end

% Set the values template variable
d.var(v) = setStateIndices( var, dim, index, takeMean, nanflag );

end