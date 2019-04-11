function[] = nanRowError( rowNaN, var, varDim )
%% Creates a very detailed error message if all the rows are nan

% Get an allnan row
allnan = find( rowNaN == max(rowNaN), 1, 'first' );
    
% Get subscript indices for the state vector
stateDim = find( var.isState );
stateSize = varDim( stateDim );
subState = subdim( stateSize, (1:prod(stateSize))' );
    
% Get the subscript indices for the all NaN row
subState = subState( allnan, : );

% Initialize an error message
msg = '';

% For each state dimension
for dim = 1:numel(stateDim)
    d = stateDim(dim);

    % If non-singleton
    if var.dimSize(d) > 1

        % Get the state index associated with the subscript index
        stateDex = var.indices{d}( subState(dim) );

        % Build the error message
        msg = [msg; sprintf('\tThe %s dimension at grid index %.f\n', var.dimID(d), stateDex)]; %#ok<AGROW>
    end
end

% Throw the final error message
error( [...
    sprintf('A state vector element for variable %s has all NaN values. This is the element associated with:\n', var.name), ...
    sprintf('%s', msg), ...
    'Consider removing this index from the state vector design.'] );

end         