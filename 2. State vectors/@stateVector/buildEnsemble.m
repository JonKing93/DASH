function[X] = buildEnsemble(obj, nEns, random)
%% Builds an ensemble...
% 
% X = obj.buildEnsemble(nEns, random)

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

% Get state vector index limits for each variable
nVars = numel(obj.variables);
svLimit = zeros(nVars+1, 2);
for v = 1:nVars
    svLimit(v+1, 1) = svLimit(v,2)+1;
    svLimit(v+1, 2) = svLimit(v,2) + prod(obj.variables(v).stateSize);
end
svLimit(1,:) = [];
    
% Preallocate the ensemble
nState = svLimit(end, 2);
X = NaN(nState, nEns);

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

% Get the sets of coupled variables. Initialize selected and unused
% ensemble members.
sets = unique(obj.coupled, 'rows');
nSets = size(sets, 1);
obj.subMembers = cell(nSets, 1);
obj.unused = cell(nSets, 1);

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
                noMatchingMetadataError(obj.variableNames(v), dims(d));
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
    % until the ensemble is complete.
    while nNeeded > 0
        if nNeeded > numel(unused)
            notEnoughMembersError(obj.variableNames(v), obj.overlap(v));
        end
        
        % Select members randomly or in an ordered manner. 
        if random
            members = unused(randsample(numel(unused), nNeeded));
        else
            members = unused(1:nNeeded);
        end

        % Get the subscript indices of ensemble members
        [subIndexCell{:}] = ind2sub(siz, members);
        subMembers(nEns-nNeeded+1:nEns, :) = cell2mat(subIndexCell);
        
        % Optionally remove ensemble members with overlapping data. Update
        % the number of ensemble members needed
        for k = 1:numel(v)
            if ~obj.overlap(v(k))
                subMembers = obj.variables(v(k)).removeOverlap(subMembers);
            end
        end
        nNeeded = nEns - size(subMembers, 1);
    end
    
    % Record the selected and unused ensemble members
    obj.subMembers{s} = subMembers;
    obj.unused{s} = unused;
    
    % Build the ensemble for each variable
    for k = 1:numel(v)
        varIndices = svLimit(v(k),1) : svLimit(v(k),2);
        X(varIndices, :) = obj.variables(v(k)).buildEnsemble( subMembers, dims, sources{f(v(k))} );
    end
end

end

% Long error messages
function[] = badGridfileError(var, ME)
message = sprintf('Could not build the gridfile object for variable %s.', var.name);
cause = MException('DASH:stateVector:badGridfile', message);
ME = addCause(ME, cause);
rethrow(ME);
end
function[] = noMatchingMetadataError(varNames, dim)
error(['Cannot couple variables %s because they have no common metadata ', ...
    'along the "%s" dimension.'], dash.messageList(varNames), dim);
end
function[] = notEnoughMembersError(varNames, overlap)
if numel(varNames) == 1
    str1 = "non-overlapping";
    str3 = 'or allowing overlap';
    if overlap
        str1 = sprintf('\b');
        str3 = sprintf('\b');
    end
    str2 = sprintf('variable "%s"', varNames);
else
    str1 = sprintf('\b');
    str2 = sprintf('couple variables %s', dash.messageList(varNames));
    if sum(~overlap)==1
        str2 = strcat(str2, sprintf(' with no overlap for variable "%s"', varNames(overlap)));
    elseif sum(~overlap)>1
        str2 = strcat(str2, sprintf(' with no overlap in variables %s', dash.messageList(varNames(overlap))));
    end
    str3 = '.';
    if any(~overlap)
        str3 = 'or allowing overlap';
    end
end
error(['Cannot find %.f %s ensemble members for %s. Consider using fewer ', ...
    'ensemble members %s.'], nEns, str1, str2, str3);
end