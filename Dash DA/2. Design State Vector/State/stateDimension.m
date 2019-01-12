function[d] = stateDimension( d, var, dim, index, takeMean, nanflag )

% Setup for the edit. Get indices, metadata, template variable, coupled
% variables.
[v, var, meta, index, coupled] = setupEdit( d, var, dim, index, 'state' );

% If a coupled ensemble dimension, ask the user to continue and uncouple
if ~var.isState(d) && any(d.isCoupled(v,:))
    flipDimWarning('ensemble', 'state', dim, var, d, d.isCoupled(v,:));    
    d = uncoupleVariables( d, [var.name; d.varName(d.isCoupled(v,:))], 'ens' ); 
end

% Restrict the metadata to the state indices
meta = meta(index);

% For each coupled variable
for c = coupled
    
    % Get the state indices
    stateDex = getCoupledIndex( d.var(c), dim, meta );
    
    % Set the values
    d.var(c) = setStateIndices( d.var(c), dim, stateDex{c}, takeMean, nanflag );
end

% Set the values template variable
d.var(v) = setStateIndices( var, dim, index, takeMean, nanflag );

end