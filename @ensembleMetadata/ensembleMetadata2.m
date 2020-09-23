function obj = ensembleMetadata(sv)
%% Returns an ensembleMetadata object for a stateVector, ensemble, or .ens file.
%
% obj = ensembleMetadata(sv)
% Creates an ensembleMetadata object for a state vector.
%
% obj = ensembleMetadata(ensfile)
% Returns the ensembleMetadata object for an ensemble saved in a .ens file.
%
% obj = ensembleMetadata(ens)
% Returns the ensembleMetadata object for an ensemble.
%
% ----- Inputs -----
%
% sv: A stateVector object

% !!!!!!!!!!!!!!!!!!!!!!!!
% Currently only building for state vector

% Error check
if ~isa(sv, 'stateVector') || ~isscalar(sv)
    error('sv must be a scalar stateVector object.');
end

% Get names
obj.ensembleName = [];
obj.vectorName = sv.name;

% Variable indexing
obj.variableNames = sv.variableNames;
obj.varLimit = sv.variableLimits;

% Preallocate dimensions
nVars = numel(obj.variableNames);
obj.dims = cell(nVars, 1);
obj.stateSize = cell(nVars, 1);

% Get the coupling index for each variable
sets = unique(obj.coupled, 'rows');
for v = 1:nVars
    s = find(sets(:,v));
    
    % Get the gridfile
    var = obj.variables(v);
    grid = var.gridfile;
    var.checkGrid(grid);
    
    % Dimensions and sizes. Initialize metadata
    obj.dims{v} = var.dims;
    obj.stateSize{v} = var.stateSize;
    obj.metadata = struct();
    
    % State dimension metadata
    d = find(grid.isdefined & var.isState);
    for k = 1:numel(d)
        dim = var.dims(d(k));
        state = var.dimMetadata(grid, dim);
        ensemble = [];
        
        % Propagate mean metadata along the third dimension
        if var.takeMean(d(k))
            state = permute(state, [3 2 1]);
        end
    end
    
    % Ensemble dimensions setup
    d = var.checkDimensions(obj.dims{s});
    for k = 1:numel(d)
        dim = var.dims(d(k));
        
        % Reference indices and ensemble metadata
        members = sv.subMembers{s}(:, k);
        ref = var.indices{d(k)}(members);
        ensemble = grid.meta.(dim)(ref, :);
        
        % Sequences are state metadata
        state = var.seqMetadata{d(k)};
    end
    
    % Build the dimension metadata structure
    obj.metadata.(var.name).(dim).state = state;
    obj.metadata.(var.name).(dim).ensemble = ensemble;
end

end
    
    
    
    
    