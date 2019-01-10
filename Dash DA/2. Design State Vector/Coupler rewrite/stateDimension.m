function[] = stateDimension( design, var, dim, index, takeMean, nanflag )

%%%%% Defaults
if ~exist('takeMean','var')
    takeMean = false;
end
if ~exist('nanflag','var')
    nanflag = 'includenan';
end
%%%%%

% Get the variable design
v = checkDesignVar(design, var);
var = design.varDesign(v);

% Get the dimension index
d = checkVarDim( var, dim );

% Check the indices are allowed
checkIndices(var, d, index);

% Get the metadata for the variable
meta = metaGridfile( var.file );
meta = meta.( var.dimID{d} );

% Get the variables with coupled state indices.
coupled = design.coupleState(v,:);
coupVars = design.varDesign(coupled);

% Preallocate state indices for each coupled variable
nCoup = sum(coupled);
stateDex = cell(nCoup,1);

% Get the state indices for each coupled variable. (But don't set any
% values until every variable successfully generates indices.)
for c = 1:nCoup
    stateDex{c} = getCoupledStateIndex( coupVars(c), dim, meta );
end

% Set the values.
setStateIndices( var, dim, index );
for c = 1:nCoup
    setStateIndices( coupVars(c), dim, stateDex{c}, takeMean, nanflag );
end

end