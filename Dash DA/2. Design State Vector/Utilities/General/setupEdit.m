function[v, index, d] = setupEdit( design, var, dim, index, dimType )
%% Setup for an edit of an ensemble or state dimension.

% Get the variable design
v = checkDesignVar(design, var);
var = design.var(v);

% Get the dimension index
d = checkVarDim( var, dim );

% Index must be a vector
if ~isvector(index)
    error('Indices must be a vector.');
end

% Convert 'all' to every dimension index
if strcmpi(index, 'all')
    index = 1:var.dimSize(d);
    
% For [], leave as current setting
elseif isempty(index)
    index = var.indices{d};

% If the indices are logicals...
elseif islogical(index)
    
    % Check that they match the dimension size
    if length(index) ~= var.dimSize(d)
        error('The length of the logical index vector does not match the size of dimension %s in variable %s.', dim, var.name);
    end    
    
    % Convert to linear index
    index = find(index);
end

% Check the indices are allowed
checkIndices(var, d, index);

% If a state dimension
flip = false;
fromTo = ['state', 'ensemble'];
if strcmpi(dimType, 'state')
    
    % Get dimensional metadata
    meta = var.meta.(var.dimID{d});
    
    % Synced field name
    field = 'syncState';
    
    % Check for changing type
    if ~var.isState(d)
        flip = true;
        fromTo = fliplr(fromTo);
    end
    
% Ensemble dimension field name
elseif strcmpi(dimType,'ens')
    field = 'isCoupled';
    
    % Check for changing type
    if var.isState
        flip = true;
    end
    
% Otherwise throw error
else
    error('Unrecognized dimType');
end

% Get the coupled / synced variables.
coupled = design.(field)(v,:);

% If coupled and changing type, going to change the type of all coupled
% variables. Ask the user to continue before proceeding.
if flip && ~isempty(coupled)
    flipDimWarning( dim, var.name, fromTo, design.varName(coupled));
end
    
end