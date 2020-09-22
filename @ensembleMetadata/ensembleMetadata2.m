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

% Get the sets of coupled variables
sets = unique(obj.coupled, 'rows');

% Get the gridfile
for v = 1:numel(obj.variableNames)
    var = obj.variables(v);
    grid = var.gridfile;
    var.checkGrid(grid);
    
    % Get metadata for state dimensions
    d = find( grid.isdefined & var.isState );
    stateMeta = struct();
    for k = 1:numel(d)
        dim = var.dims(d(k));
        stateMeta.(dim) = var.dimMetadata(grid, dim);
        
        % Propagate metadata for means along the third dimension
        if var.takeMean(d(k))
            stateMeta.(dim) = permute(stateMeta.(dim), [3 2 1]);
        end
    end
    
    % Get indices for the ensemble dimensions and coupling set
    d = find(~var.isState);
    s = find(sets(:,v));
    
    % Intialize the metadata across the ensemble
    dims = var.dims(d);
    nSeq = var.stateSize(d);
    ensMeta = struct('dims', dims, 'nSeq', nSeq);
    
    % Get the reference indices used for each ensemble member
    for k = 1:numel(d)
        dim = var.dims(d(k));
    
    
    
    

    % Get the metadata at the reference indices for each ensemble member
    for k = 1:numel(d)
        dim = var.dims(d(k));        
        meta = var.dimMetadata(grid, dim);
        [~, col] = ismember(dim, obj.dims{s});
        ensMeta.(dim) = meta(obj.subMembers{s}(:,col), :);
        
        % 
        
        
        
    
    
    
    
    
    