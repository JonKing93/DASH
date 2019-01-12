function[v, var, meta, index, coupled] = setupEdit( design, var, dim, index, dimType )

% Get the variable design
v = checkDesignVar(design, var);
var = design.var(v);

% Get the dimension index
d = checkVarDim( var, dim );

% Get file metadata
[meta, dimID, dimSize] = metaGridfile( var.file );

% Convert 'all' to every dimension index
if strcmpi(index, 'all')
    index = 1:dimSize(d);
end

% Check the indices are allowed
checkIndices(var, d, index);

% Get the metadata for the dimension
meta = meta.(dimID{d});

% Get the coupling field name
field = isCoupled;
if strcmpi(dimType,'state')
    field = 'coupleState';
end

% Get the variables with coupled indices
coupled = find( design.(field)(v,:) );

end