function[X, meta, obj] = build(obj, nEns, random, filename, overwrite, showprogress)
%% Builds a state vector ensemble.
%
% 

% Defaults
if ~exist('random','var') || isempty(random)
    random = true;
end
if ~exist('filename','var') || isempty(filename)
    filename = string([]);
end
if ~exist('overwrite','var') || isempty(overwrite)
    overwrite = false;
end
if ~exist('showprogress','var') || isempty(showprogress)
    showprogress = true;
end

% Error check
if ~isscalar(nEns)
    error('nEns must be a scalar.');
end
dash.assertPositiveIntegers(nEns, 'nEns');
dash.assertScalarLogical(random, 'random');
dash.assertScalarLogical(overwrite, 'overwrite');
dash.assertScalarLogical(showprogress, 'showprogress');

% Check that each variable has both state and ensemble dimensions
nVars = numel(obj.variables);
for v = 1:nVars
    if ~any(obj.variables(v).isState)
        badDimensionsError(obj.variables(v).name, true);
    elseif ~any(~obj.variables(v).isState)
        badDimensionsError(obj.variables(v).name, false);
    end
    
    % Trim reference indices to only allow complete means and sequences.
    obj.variables(v) = obj.variables(v).trim;
end

% Pre-build gridfiles and data sources. Check that gridfiles are valid.
[grids, sources, f] = obj.prebuildSources;

% Get the sets of coupled variables. Initialize selected and unused
% ensemble members.
sets = unique(obj.coupled, 'rows');
nSets = size(sets, 1);
obj.unused = cell(nSets, 1);
obj.subMembers = cell(nSets, 1);

% Get the ensemble dimensions associated with each set of coupled variables
for s = 1:nSets
    v = find(sets(s,:));
    var1 = obj.variables(v(1));
    dims = var1.dims(~var1.isState);
    obj.dims{s} = dims;
    
    % Find metadata that is in all of the variables in the set.
    for d = 1:numel(dims)
        meta = var1.dimMetadata(grids{f(v(1))}, dims(d));
        for k = 2:numel(v)
            varMeta = obj.variables(v(k)).dimMetadata( grids{f(v(k))}, dims(d) );
            
            % Get the metadata intersect
            if dash.bothNaN(meta, varMeta)
                meta = NaN;
            else
                try
                    meta = intersect(meta, varMeta, 'rows', 'stable');

                % Informative errors if there is no overlap or different formats
                catch
                    incompatibleFormatsError(obj, v(1), v(k), dims(d));
                end
                if isempty(meta)
                    noMatchingMetadataError(obj.variableNames(v), dims(d));
                end
            end
        end

        % Update the reference indices in each variable to match the metadata
        for k = 1:numel(v)
            obj.variables(v(k)) = obj.variables(v(k)).matchIndices(meta, grids{f(v(k))}, dims(d));
        end
        
        % ***Note: At this point, the reference indices in the coupled
        % variables are in the same order. The first reference index in each
        % variable points to the same metadata-1. The second reference index in
        % each points to the same metadata-2, etc.
    end
    
    % Initialize the unused ensemble members
    obj.unused = (1:prod(obj.variables(v(1)).ensSize))';
    if random
        obj.unused = obj.unused( randperm(numel(obj.unused)) );
    end
end

% If writing to file: get path, set extension, check overwriting
ens = [];
writeFile = false;
if ~isempty(filename)
    filename = dash.assertStrFlag(filename, 'filename');
    filename = dash.setupNewFile(filename, '.ens', overwrite);
    writeFile = true;
    
    % Initialize the new matfile
    if isfile(filename)
        delete(filename);
    end
    ens = matfile(filename);
    ens.X = NaN(0,0);
end

% Build the ensemble
try
    [X, meta, obj] = obj.buildEnsemble(nEns, grids, sources, f, ens, showprogress);
    
% Deleted any failed .ens files before throwing errors
catch ME
    if writeFile && isfile(filename)
        delete(filename);
    end
    rethrow(ME);
end

% If requested, return output array when saving to file
if writeFile && nargout>0
    try
        X = ens.X;
    catch
        loadTooBigError(filename);
    end
end

end

% Long error messages
function[] = badDimensionsError(name, noState)
type = "ensemble";
if noState
    type = "state";
end
error(['Variable "%s" has no %s dimensions. See "stateVector.design" to ',...
    'specify %s dimensions.'], name, type, type);
end
function[] = incompatibleFormatsError(obj, v1, v, dim)
error(['Coupled variables "%s" and "%s" use different metadata formats for ', ...
    'the "%s" dimension.'], obj.variables(v1).name, obj.variables(v).name, dim);
end
function[] = noMatchingMetadataError(varNames, dim)
error(['Cannot couple variables %s because they have no common metadata ', ...
    'along the "%s" dimension. This can occur when metadata for different ',...
    'variables are in different formats. If this is the case, consider using ',...
    'either the "stateVector.specifyMetadata" or "stateVector.convertMetadata" ',...
    'method.'], dash.messageList(varNames), dim);
end
function[] = loadTooBigError(filename)
warning(['The state vector ensemble was successfully written to file "%s". ', ...
    'However, the ensemble is too large to fit in active memory, so cannot ',...
    'be provided directly as output. Use the "ensemble" class to interact ',...
    'with the state vector ensemble instead.'], filename);
end