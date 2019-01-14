function[v, var, meta, index, coupled, design] = setupEdit( design, var, dim, index, dimType )

% Get the variable design
v = checkDesignVar(design, var);
var = design.var(v);

% Get the dimension index
d = checkVarDim( var, dim );

% Get file metadata
[meta, dimID, dimSize] = metaGridfile( var.file );

% Index must be a vector
if ~isvector(index)
    error('Indices must be a vector.');
end

% Convert 'all' to every dimension index
if strcmpi(index, 'all')
    index = 1:dimSize(d);

% If the indices are logicals...
elseif islogical(index)
    
    % Check that they match the dimension size
    if length(index) ~= dimSize(d)
        error('The length of the logical index vector does not match the size of dimension %s in variable %s.', dim, var.name);
    end    
    
    % Convert to linear index
    index = find(index);
end

% Check the indices are allowed
checkIndices(var, d, index);

% Get the metadata for the dimension
meta = meta.(dimID{d});

% Get some state vs ensemble values
if strcmpi(dimType, 'state')
    field = 'coupleState';
    fromTo = {'ensemble','state'};
    flip = ~var.isState(d);
    uncoup = 'ens';
elseif strcmpi(dimType,'ens')
    field = 'isCoupled';
    fromTo = {'state','ensemble'};
    flip = var.isState(d);
    uncoup = 'state';
else
    error('Unrecognized dimType');
end

% Get the variables with coupled indices
coupled = find( design.(field)(v,:) );

% If a coupled dimension and changing type, ask the user to continue and
% uncouple
uncouple = design.(field)(v,:);
if flip && any( uncouple )
    flipDimWarning( fromTo{1}, fromTo{2}, dim, var, design, uncouple );
    design = uncoupleVariables( design, [var.name; design.varName(uncouple)], uncoup );
end
    
end