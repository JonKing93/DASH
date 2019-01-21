function[design] = stateDimension( design, var, dim, index, takeMean, nanflag )
%% Edits a state dimension.

% Setup for the edit. Get indices, metadata, template variable, coupled
% variables.
[v, index, d] = setupEdit( design, var, dim, index, 'state' );

% Get any synced variables
synced = find( design.syncState(v,:) );

% Check for changing type

% Get the metadata for the dimension
meta = design.var(v).meta.( design.var(v).dimID{d} );
meta = meta(index);

% For each synced variable
for k = 1:numel(synced)
    
    % Get the state indices with matching metadata
    stateDex = getMatchingMetaDex( design.var(synced(k)), dim, meta, true );
    
    % Set the values
    design.var(synced(k)) = setStateIndices( design.var(sv), dim, stateDex, takeMean, nanflag );
end

% Set the values for the variable.
design.var(v) = setStateIndices( design.var(v), dim, index, takeMean, nanflag );

end