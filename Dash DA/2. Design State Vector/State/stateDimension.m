function[design] = stateDimension( design, var, dim, index, takeMean, nanflag )

%%%%% Defaults
if ~exist('takeMean','var') || isempty(takeMean)
    takeMean = false;
end
if ~exist('nanflag','var') || isempty(nanflag)
    nanflag = 'includenan';
end
%%%%%

% Get the variable design
v = checkDesignVar(design, var);
var = design.var(v);

% Get the dimension index
d = checkVarDim( var, dim );

% Check the indices are allowed
checkIndices(var, d, index);

% Get the metadata for the variable at the indices
meta = metaGridfile( var.file );
meta = meta.( var.dimID{d} );
meta = meta(index);

% Get the variables with coupled state indices.
coupled = find( design.coupleState(v,:) );
coupVars = design.var(coupled);

% For each coupled variable
for c = 1:numel(coupled)
    
    % Get the state indices
    stateDex = getCoupledIndex( coupVars(c), dim, meta );
    
    % Set the values
    coupVars(c) = setStateIndices( coupVars(c), dim, stateDex{c}, takeMean, nanflag );
end

% Set the values in the design. Also set the template variable
design.var(v) = setStateIndices( var, dim, index, takeMean, nanflag );
design.var(coupled) = coupVars;

end