function[X] = buildEnsemble(obj, nEns, random)
%% Builds an ensemble...
% 
% X = obj.buildEnsemble(nEns, random)

% Here be dragons

% Default
if ~exist('random','var') || isempty(random)
    random = true;
end

% Error check
dash.assertScalarLogical(random);
if ~isscalar(nEns) || ~isnumeric(nEns)
    error('nEns must be a numeric scalar.');
end
dash.assertPositiveIntegers(nEns, 'nEns');

%% Gridfile and Trim
% vf: Variable index associated with file
% f: File index associated with variable
% v: Index of variable in the state vector.

% Get the .grid files associated with each variable.
nVar = numel(obj.variables);
files = cell(nVar, 1);
[files{:}] = deal(obj.variables.file);
files = string(files);

% Find the unique gridfiles. Preallocate data source arrays
[files, vf, f] = unique(files);
nGrids = numel(files);
grids = cell(nGrids, 1);
sources = cell(nGrids, 1);

% Check the gridfile can still be built for each variable. Do an internal
% review and get the data source array.
nVar = numel(obj.variables);
for v = 1:nVar
    if ismember(v, vf)
        try
            grids{f(v)} = gridfile(obj.variables(v).file);
        catch ME
            badGridfileError(obj.variables(v), ME);
        end        
        sources{f(v)} = grids{f(v)}.review;
    end
    
    % Check the grid matches the values recorded by the variable. Trim
    % reference indices to only allow complete means and sequences.
    obj.variables(v).checkGrid(grid);
    obj.variables(v) = obj.variables(v).trim;
end

%% Coupled variables: Match metadata, Prevent overlap
% s: The index for a set of coupled variables
% v: The indices of variables in a set

% Get the sets of coupled variables
sets = unique(obj.coupled, 'rows');
nSets = size(sets, 1);

% Get the ensemble dimensions associated with each set of coupled variables
for s = 1:nSets
    v = find(sets(s,:));
    var1 = obj.variables(v(1));
    dims = var1.dims(~var1.isState);
    
    % Find metadata that is in all of the variables in the set.
    for d = 1:numel(dims)
        meta = var1.dimMetadata(grids{f(v(1))}, dims(d));
        for k = 2:numel(v)
            meta = obj.variables(v(k)).matchingMetadata(meta, grids{f(v(k))}, dims(d));
            if isempty(meta)
                noMatchingMetadataError();
            end
        end
        
        % Update the reference indices in each variable to match the metadata
        for k = 1:numel(v)
            obj.variables(v(k)) = obj.variables(v(k)).matchIndices(meta, grids{f(v(k))}, dims(d));
        end
    end
    
    % ***Note: At this point, the reference indices in the coupled
    % variables are in the same order. The first reference index in each
    % variable points to the same metadata-1. The second reference index in
    % each points to the same metadata-2, etc.
    
    % Initialize a set of subscripted ensemble members
    subMembers = NaN(nEns, numel(dims));
    unused = (1:prod(obj.ensSize))';
    nNeeded = nEns;
    subIndexCell = cell(1, numel(dims));
    siz = var1.ensSize(~var1.isState);
    
    % Select ensemble members and optionally remove overlapping members
    % until the ensemble is complete
    while nNeeded > 0
        
        % Select members randomly or in an ordered manner. 
        if random
            members = unused(randsample(numel(unused), nNeeded));
        else
            members = unused(1:nNeeded);
        end

        % Get the subscript indices of ensemble members
        [subIndexCell{:}] = ind2sub(siz, members);
        subMembers(end-nNeeded+1:end, :) = cell2mat(subIndexCell);
        
        % Optionally remove ensemble members with overlapping data
        for k = 1:numel(v)
            if ~obj.overlap(k)
                subMembers = obj.variables(v(k)).removeOverlap(subMembers);
            end
        end
                
    
            
            
            
    
    


    
    
    
    
    
    


















end

% Long messages
function[] = badGridfileError(var, ME)
message = sprintf('Could not build the gridfile object for variable %s.', var.name);
cause = MException('DASH:stateVector:badGridfile', message);
ME = addCause(ME, cause);
rethrow(ME);
end
