function[X, meta, obj] = buildEnsemble(obj, nEns, random, filename, overwrite, showprogress)
%% Builds a state vector ensemble.
% 
% [X, meta, obj] = obj.buildEnsemble(nEns)
% Builds a state vector ensemble with a specified member of ensemble
% members. Returns the state vector ensemble and associated metadata. Also
% returns a stateVector object that can be used to build additional state
% vectors for the ensemble later.
%
% [...] = obj.buildEnsemble(nEns, random)
% Specify whether to select ensemble members at random, or sequentially.
% Default is random selection.
%
% obj.buildEnsemble(nEns, random, filename)
% Saves the state vector ensemble to a .ens file. Uses a ".ens" extension
% if the file name does not already have one.
%
% obj.buildEnsemble(nEns, random, filename, overwrite)
% Specify whether to overwrite existing .ens files. Default is to not
% overwrite existing files.
%
% obj.buildEnsemble(nEns, random, filename, overwrite, showprogress)
% Specify whether to display a progress bar. Default is to show a progress
% bar.
%
% ----- Inputs -----
%
% nEns: The number of ensemble members. A positive integer.
%
% random: Scalar logical. If true (default), selects ensemble members at
%    random. If false, selects ensemble members sequentially.
%
% file: The name of a .ens file. A string. Use only a file name to write to
%    the current directory. Use a full path to write to a specific
%    location. Use an empty array to not write to file.
%
% overwrite: A scalar logical indicating whether to overwrite existing .ens
%    files (true) or not overwrite files (false -- default).
%
% showprogress: A scalar logical indicating whether to display a progress
%    bar (true -- default), or not (false).
%
% ----- Outputs -----
%
% X: The state vector ensemble. A numeric matrix. (nState x nEns)
%
% meta: An ensembleMetadata object for the ensemble.
%
% obj: A stateVector object associated with the ensemble. Can be used to
%    generate additional ensemble members later.

%% Input error checks

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

% Basic error check
if ~isscalar(nEns)
    error('nEns must be a scalar.');
end
dash.assertPositiveIntegers(nEns, 'nEns');
dash.assertScalarLogical(random, 'random');
dash.assertScalarLogical(overwrite, 'overwrite');
dash.assertScalarLogical(showprogress, 'showprogress');
nVars = numel(obj.variables);


%% Check and setup variables: state/ensemble dimensions, gridfiles, trim
% v: Index of variable in the state vector
% f: File index associated with variable
% vf: Variable index associated with file

% Get the .grid files associated with each variable.
files = dash.collectField(obj.variables, 'file');
files = string(files);

% Find the unique gridfiles. Preallocate data sources, grids, and the limits
% of each variable in the state vector
[files, vf, f] = unique(files);
nGrids = numel(files);
grids = cell(nGrids, 1);
sources = cell(nGrids, 1);

% Check that all gridfiles are valid. Pre-build data sources
for v = 1:nVars
    if ismember(v, vf)
        grids{f(v)} = obj.variables(v).gridfile;
        sources{f(v)} = grids{f(v)}.review;
    end
    obj.variables(v).checkGrid(grids{f(v)});

    % Check that each variable has both state and ensemble dimensions
    if ~any(obj.variables(v).isState)
        badDimensionsError(obj.variables(v).name, true);
    elseif ~any(~obj.variables(v).isState)
        badDimensionsError(obj.variables(v).name, false);
    end
    
    % Trim reference indices to only allow complete means and sequences.
    obj.variables(v) = obj.variables(v).trim;
end


%% Coupled variables: Match metadata, select ensemble members, remove overlap
% s: The index for a set of coupled variables
% v: The indices of variables in a set
% dims: Ensemble dimensions for a set
% d: Iterator for dims
% k: Iterator for v

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
    end

    % ***Note: At this point, the reference indices in the coupled
    % variables are in the same order. The first reference index in each
    % variable points to the same metadata-1. The second reference index in
    % each points to the same metadata-2, etc.

    % Initialize a set of subscripted ensemble members
    subMembers = NaN(nEns, numel(dims));
    nNeeded = nEns;
    subIndexCell = cell(1, numel(dims));
    siz = var1.ensSize(~var1.isState);
    
    % Get the set of all ensemble members. Order randomly or sequentially
    unused = (1:prod(obj.variables(v(1)).ensSize))';
    if random
        unused = unused( randperm(numel(unused)) );
    end

    % Select ensemble members and optionally remove overlapping members
    % until the ensemble is complete.
    while nNeeded > 0
        if nNeeded > numel(unused)
            notEnoughMembersError(obj.variableNames(v), obj.overlap(v), nEns);
        end

        % Select members. Remove values from the unused members when selected
        members = unused(1:nNeeded);
        unused(1:nNeeded) = [];

        % Get the subscript indices of ensemble members
        [subIndexCell{:}] = ind2sub(siz, members);
        subMembers(nEns-nNeeded+1:nEns, :) = cell2mat(subIndexCell);

        % Optionally remove ensemble members with overlapping data. Update
        % the number of ensemble members needed
        for k = 1:numel(v)
            if ~obj.overlap(v(k))
                subMembers = obj.variables(v(k)).removeOverlap(subMembers, dims);
            end
        end
        nNeeded = nEns - size(subMembers, 1);
    end

    % Record the ensemble members, ensemble dimensions, and unused members
    obj.subMembers{s} = subMembers;
    obj.dims{s} = dims;
    obj.unused{s} = unused;
end


%% Build the ensemble
% v: Variable index in the state vector
% s: Set index associated with a variable

% Note if writing to file. Get full path, set extension, check overwriting
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
end

% Catch any failed .ens files
try

    % Get the variable limits and preallocate the ensemble
    varLimit = obj.variableLimits;
    nState = varLimit(end, 2);
    if writeFile
        ens.X(nState, nEns) = NaN;
        ens.hasnan = false(nVars, nEns);
    else
        try
            X = NaN(nState, nEns);
        catch
            outputTooBigError();
        end
    end

    % Get the state vector rows and coupling set for each variable. Collect the
    % inputs for svv.buildEnsemble
    for v = 1:nVars
        rows = varLimit(v,1):varLimit(v,2);
        s = find( sets(:,v) );

        % Build the ensemble for the variable. Get array or save to file
        inputs = {obj.subMembers{s}, obj.dims{s}, grids{f(v)}, sources{f(v)}, [], [], showprogress};
        if writeFile
            inputs(5:6) = {ens, rows};
            hasnan = obj.variables(v).buildEnsemble( inputs{:} );
            ens.hasnan(v, :) = hasnan;
        else
            X(rows,:) = obj.variables(v).buildEnsemble( inputs{:} );
        end
    end

    % Ensemble metadata
    meta = ensembleMetadata(obj);
    if writeFile
        ens.meta = meta;
        ens.stateVector = obj;
    end

% Delete any failed ensembles before throwing errors
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
function[] = notEnoughMembersError(varNames, overlap, nEns)
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
function[] = outputTooBigError()
error(['The state vector ensemble is too large to fit in active memory, so ',...
    'cannot be provided directly as output. Consider saving the ensemble ',...
    'to a .ens file instead.']);
end
function[] = loadTooBigError(filename)
warning(['The state vector ensemble was successfully written to file "%s". ', ...
    'However, the ensemble is too large to fit in active memory, so cannot ',...
    'be provided directly as output. Use the "ensemble" class to interact ',...
    'with the state vector ensemble instead.'], filename);
end