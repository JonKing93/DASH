function[design] = stateDimension( design, var, dim, index, takeMean, nanflag )
%% Edits a state dimension.

% Parse the inputs
[index, takeMean, nanflag] = parseInputs( varargin, {'index','mean','nanflag'}, {[],[],[]}, {[],[],{'omitnan','includenan'}} );

% Get the variable index
v = checkDesignVar( design, var );

% Get the dimension index
d = checkVarDim( var, dim );

%% Get the values to use

% Get the indices to use
if isempty(index)
    index = design.var(v).indices{d};
elseif strcmpi(index, 'all')
    index = 1:design.var(v).dimSize(d);
end

% Get the value of takeMean
if isempty(takeMean)
    takeMean = design.var(v).takeMean(d);
end
if ~islogical(takeMean) || ~isscalar(takeMean)
    error('takeMean must be a logical scalar.');
end

% Get the nanflag
if isempty(nanflag)
    nanflag = design.var(v).nanflag{d};
end


%% Sync / Couple

% Get any coupled variables
cv = design.isCoupled(v,:);














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