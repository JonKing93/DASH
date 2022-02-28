function[X, meta, obj] = build(obj, nMembers, varargin)
%% stateVector.build  Build a state vector ensemble
% ----------
%   [X, metadata, obj] = obj.build(nMembers)
%   Builds a state vector ensemble with the specified number of ensemble
%   members and returns the ensemble as output. If the state vector
%   includes sequences or means, the method ensures that only ensemble
%   members with complete sequences and means are built.
%
%   The built ensemble is a matrix with one column per ensemble member. As
%   the second output, the method returns an ensembleMeatdata object, which
%   organizes metadata along the rows and columns of the ensemble. The
%   final output is the state vector object for the built ensemble, which
%   can be used to add more members to the ensemble if necessary.
%
%   ... = obj.build('all')
%   Builds a state vector ensemble with as many ensemble members as
%   possible. Reports the number of ensemble members being built to the
%   console.
%
%   obj.build(..., 'sequential', true | false)
%   obj.build(..., 'sequential', buildSequentially)
%   Specify whether ensemble members should be selected sequentially along
%   the ensemble dimensions, or at random. The default behavior is random
%   selection. Use this option if, for example, you want the ensemble
%   members to remain ordered in time.
%
%   [ens, metadata, obj] = obj.build(..., 'file', filename)
%   Saves the state vector ensemble to a .ens file of the specified name.
%   The saved ensemble can then be accessed at any time using the
%   "ensemble" class. This option allows you to build ensembles that are
%   too large to fit in active memory. When writing the ensemble to file,
%   the first output is an ensemble object, which can be used to interact
%   with the ensemble saved in the file.
%
%   obj.build(..., 'file', filename, 'overwrite', true | false)
%   obj.build(..., 'file', filename, 'overwrite', overwrite)
%   Specify whether the new .ens file can overwrite an existing file.
%   Default is to not overwrite existing files.
%
%   obj.build(..., 'showprogress', true | false)
%   obj.build(...,  'showprogress', showprogress)
%   Specify whether to display a progress bar. Default is to not display a
%   progress bar.
%
%   obj.build(..., 'strict', true | false)
%   obj.build(..., 'strict', strict)
%   Specify how the method should respond if it cannot build the requested
%   number of ensemble members. If true (default), throws an error when the
%   requested number of ensemble members cannot be built. If false, issues
%   a warning (but does not fail) when the requested number of ensemble
%   members cannot be built. If this occurs, the output ensemble will have
%   fewer columns than the requested number of ensemble members.
% ----------
%   Inputs:
%       nMembers (scalar positive integer | 'all'): The number of ensemble
%           members (columns) that should be in the built ensemble. Use
%           'all' to use every possible ensemble member.
%       buildSequentially (scalar logical): True if ensemble members should
%           be selected sequentially along ensemble dimensions. False (default)
%           if ensemble members should be selected at random.
%       filename (string scalar): The name of the new ".ens" file. May be a
%           filename, relative path, or absolute path. If not an absolute
%           path, saves the new file relative to the current folder. Adds a
%           ".ens" extension to the filename if it does not already have one.
%       overwrite (scalar logical): True if the new ".ens" file can
%           overwrite existing files. False (default) if the method should
%           not overwrite existing files.
%       showprogress (scalar logical): Set to true if the method should
%           display a progress bar. Set to false (default) to not display a
%           progress bar.
%       strict (scalar logical): Specify how the method should respond if
%           the requested number of ensemble members cannot be built. If
%           true (default), throws an error. If false, issues a warning and
%           returns an ensemble with however many ensemble members did
%           successfully build.
%
%   Outputs:
%       X (numeric matrix [nState x nMembers]): The built state vector
%           ensemble. Has one row per state vector element. Each column is
%           an ensemble member.
%       ens (scalar ensemble object): An ensemble object that can be used
%           to interact with the ensemble written to file. See >> dash.doc('ensemble')
%           for more details.
%       metadata (scalar ensembleMetadata object): An ensemble metadata
%           object for the ensemble. Organizes metadata along the rows and
%           columns of the ensemble. See >> dash.doc('ensembleMetadata')
%           for more details.
%       obj (scalar stateVector object): The state vector object for the
%           built ensemble. Can be used to add additional members to the
%           ensemble. Cannot be edited in any way.
%
% <a href="matlab:dash.doc('stateVector.build')">Documentation Page</a>       

%% Error checking

% Setup. Redirect to addMembers if already built.
header = "DASH:stateVector:build";
dash.assert.scalarObj(obj, header);
if ~obj.iseditable
    addMembersError(obj, header);
end
obj.assertUnserialized;

% Error check members
if isnumeric(nMembers)
    dash.assert.scalarType(nMembers, [], 'nMembers', header);
    dash.assert.positiveIntegers(nMembers, 'nMembers', header);
elseif ~strcmp(nMembers, 'all')
    id = sprintf("%s:invalidMembers", header);
    error(id, 'nMembers must either be a scalar positive integer, or "all".');
end

% Parse the other variables
flags =    ["sequential","strict","file","overwrite","showprogress"];
defaults = {    false,     true,    [],     false,        false    };
[sequential, strict, filename, overwrite, showprogress] = dash.parse.nameValue(...
    varargin, flags, defaults, 1, header);

% Error check logical switches
dash.assert.scalarType(sequential, 'logical', 'buildSequentially', header);
dash.assert.scalarType(strict, 'logical', 'strict', header);
dash.assert.scalarType(overwrite, 'logical', 'overwrite', header);
dash.assert.scalarType(showprogress, 'logical', 'showprogress', header);

% Check file if writing. Get path, set extension, check overwrite
writeFile = ~isempty(filename);
if writeFile
    filename = dash.assert.strflag(filename, 'filename', header);
    filename = dash.file.new(filename, ".ens", overwrite, header);
end

% Require the state vector to have at least 1 variable
if obj.nVariables==0
    noVariablesError(obj, header);
end

% Require each variable to have at least 1 ensemble dimension
for v = 1:obj.nVariables
    variable = obj.variables_(v);
    ensDims = variable.dimensions('ensemble');
    if numel(ensDims)==0
        noEnsembleDimensionsError(obj, v, header);
    end
end

% Initialize the progress bar
if showprogress
    progress = progressbar;
    progress.handle = waitbar(0);
else
    progress = [];
end


%% Finalize variables

% Initialize progress bar
if showprogress
    waitbar(0, progress.handle, 'Finalizing Variables: 0%');
end

% Cycle through variables, fill in placeholder values
for v = 1:obj.nVariables
    obj.variables_(v) = obj.variables_(v).finalize;

    % Trim reference indices to only allow complete sequences and means
    obj.variables_(v) = obj.variables_(v).trim;

    % Informative error if no members are possible
    [siz, dims] = obj.variables_(v).ensembleSizes;
    if any(siz==0)
        noCompleteEnsembleMembersError(obj, v, siz, dims, header);
    end

    % Update progress
    if showprogress
        x = v/obj.nVariables;
        message = sprintf('Finalizing Variables: %.f%%', 100*x);
        waitbar(x, progress.handle, message);
    end
end


%% Gridfiles

% Build gridfiles
[grids, failed, cause] = obj.buildGrids(obj.gridfiles);
if failed
    gridfileFailedError;
end

% Check gridfiles match recorded values
vars = 1:obj.nVariables;
[failed, cause] = obj.validateGrids(grids, vars, header);
if failed
    invalidGridfileError;
end


%% Match metadata

% Get coupling sets
coupling = obj.couplingInfo;
nSets = numel(coupling.sets);

% Preallocate unused, and selected ensemble members
obj.unused = cell(nSets, 1);
obj.subMembers = cell(nSets, 1);

% Cycle through sets of coupled variables
for s = 1:nSets
    set = coupling.sets(s);
    vars = set.vars;
    nCoupledVars = numel(vars);

    % Get the gridfile for each variable
    g = grids.whichGrid(vars);
    varGrids = grids.gridfiles(g);

    % Cycle through ensemble dimensions. Initialize metadata
    dims = set.dims;
    for d = 1:size(dims,2)
        metadata = getMetadata(obj, vars(1), dims(1,d), varGrids(1), header);

        % Get metadata intersect over all the coupled variables
        for v = 2:nCoupledVars
            varMetadata = getMetadata(obj, vars(v), dims(v,d), varGrids(v), header);
            try
                metadata = intersect(metadata, varMetadata, 'rows', 'stable');
            catch
                incompatibleMetadataFormatsError(...
                    obj, vars, v, set.ensDims(d), metadata, varMetadata, header);
            end

            % Throw error if there is no overlapping metadata
            if isempty(metadata)
                noMatchingMetadataError(obj, vars, set.ensDims(d), header);
            end
        end

        % Order the reference indices to match the metadata intersect
        for v = 1:nCoupledVars
            variable = obj.variables_(vars(v));
            variable = variable.matchMetadata(dims(v,d), metadata, varGrids(v));
            obj.variables_(vars(v)) = variable;
        end

        % !! Important !!
        % At this point, the reference indices in the coupled variables are
        % in the same order. The first index in each variable points to
        % metadata-1, the second to metadata-2, and so on.
    end

    % Initialize the unused ensemble members
    ensSize = obj.variables_(vars(1)).ensembleSizes;
    nInitial = prod(ensSize);
    if sequential
        unused = (1:nInitial)';
    else
        unused = randperm(nInitial)';
    end
    obj.unused{s} = unused;
end


%% Build / Write ensemble

% If writing, use a temporary file to hold the incomplete ensemble
ens = [];
if writeFile
    tmpFile = strcat(filename, ".tmp");
    cleanup = onCleanup(@()removeTmpFile(tmpFile));
    removeTmpFile(tmpFile);
    ens = matfile(tmpFile);
end

% Build the ensemble.
obj.iseditable = false;
[X, meta, obj] = obj.buildEnsemble(ens, nMembers, strict, grids, coupling, progress);

% After writing, move data from .tmp to .ens. Optionally get ensemble
% object as output
if writeFile
    movefile(tmpFile, filename);
    if nargout>0
        X = ensemble(filename);
    end
end

end


% Utility functions
function[metadata] = getMetadata(obj, v, d, grid, header)

% Get the metadata for the dimension
variable = obj.variables_(v);
[metadata, failed, cause] = variable.getMetadata(d, grid, header);

% Informative error if failed
if failed
    dim = variable.dimensions(d);
    ME = couldNotLoadMetadataError(obj, v, dim, grid, cause);
    throwAsCaller(ME);
end

end
function[] = removeTmpFile(file)
if isfile(file)
    delete(file);
end
end

% Error messages
function[] = addMembersError(obj, header)

id = sprintf('%s:vectorAlreadyHasEnsemble', header);
name = '';
if ~strcmp(obj.label, "")
    name = sprintf(' (%s)', obj.label);
end
link = '<a href="matlab:dash.doc(''stateVector.addMembers'')">stateVector.addMembers</a>';
ME = MException(id, ['This state vector object%s is already associated with ',...
    'an existing, built state vector ensemble. To add more state vectors to the ',...
    'existing ensemble, use the %s method instead.'], name, link);
throAsCaller(ME);
end
function[] = noVariablesError(obj, header)
link = '<a href="matlab:dash.doc(''stateVector.add'')">stateVector.add</a>';
id = sprintf('%s:noVariables', header);
ME = MException(id, ['You cannot build an ensemble for %s because it does not ',...
    'have any variables. See %s to add variables to the state vector'],...
    obj.name, link);
throwAsCaller(ME);
end
function[] = noEnsembleDimensionsError(obj, v, header)
link = '<a href="matlab:dash.doc(''stateVector.design'')">stateVector.design</a>';
var = obj.variables(v);
id = sprintf('%s:noEnsembleDimensions', header);
ME = MException(id, ['Cannot build an ensemble for %s because the "%s" variable ',...
    'does not have any ensemble dimensions. See %s to set ensemble dimensions ',...
    'for the variable.'], obj.name, var, link);
throwAsCaller(ME);
end
function[] = noCompleteEnsembleMembersError(obj, v, siz, dims, header)

mean = '<a href="matlab:dash.doc(''stateVector.mean'')">mean</a>';
sequence = '<a href="matlab:dash.doc(''stateVector.sequence'')">sequence</a>';
design = '<a href="matlab:dash.doc(''stateVector.design'')">design</a>';

var = obj.variables(v);
bad = find(siz==0,1);
dim = dims(bad);

id = sprintf('%s:noCompleteEnsembleMembers', header);
ME = MException(id,[...
    'Cannot build an ensemble for %s because the "%s" variable cannot ',...
    'complete any ensemble members along the "%s" dimension. This can occur ',...
    'if 1. A mean or sequence index for the dimension has a very large ',...
    'magnitude, or 2. There are very few reference indices for the dimension. ',...
    'Consider using the %s, %s, and/or %s methods to adjust these indices.'],...
    obj.name, var, dim, mean, sequence, design);
throwAsCaller(ME);

end
    
function[] = couldNotBuildGridfileError(obj, grids, whichGrid, g, cause)
link = '<a href="matlab:dash.doc(''stateVector.relocate'')">stateVector.relocate</a>';
id = cause.identifier;
v = find(whichGrid==g);
var = 'variables';
if v==1
    var = 'variable';
end
variables = obj.variables_(v);

ME = MException(id, ['Cannot build an ensemble for %s because the gridfile for ',...
    '%s %s (%s) could not be built. If the gridfile has moved from its former location, ',...
    'see the %s method.\n\ngridfile: %s'], obj.name, var, ...
    dash.string.list(variables), grids(g).name, link, grids(g).file);
ME = addCause(ME, cause);
throwAsCaller(ME);
end
function[] = invalidGridfileError(obj, v, grid, cause)
link = '<a href="matlab:dash.doc(''stateVector.relocate'')">stateVector.relocate</a>';
var = obj.variables(v);
vector = '';
if ~strcmp(obj.label, "")
    vector = sprintf('State vector: %s\n', obj.label);
end
id = cause.identifier;
ME = MException(id, ['Cannot build an ensemble for %s because the gridfile for ',...
    'variable "%s" (%s) does not match the gridfile used to create the variable. ',...
    'If the original gridfile has moved, see the %s method. If the original gridfile ',...
    'has been altered, consider rebuilding the state vector.',...
    '\n\n%sVariable: %s\ngridfile: %s%s'], ...
    obj.name, var, grid.name, link, vector, var, grid.file);
ME = addCause(ME, cause);
throwAsCaller(ME);
end
function[ME] = couldNotLoadMetadataError(obj, v, dim, grid, cause)

% Info about different types of failure
id = cause.identifier;
if contains(id, 'couldNotBuildGridfile')
    info = sprintf([' This failure occured because the gridfile for the variable (%s) failed to ',...
        'build.\n\ngridfile: %s'], grid.name, grid.file);
elseif contains(id, 'invalidGridfile')
    info = sprintf([' This failure occured because the gridfile for the variable (%s) does not ',...
        'match the gridfile used to create the variable.\n\ngridfile: %s'], grid.name, grid.file);
elseif contains(id, 'conversionFunctionFailed')
    info = ' This failure occured because the conversion function for the metadata failed to run.';
elseif contains(id, 'invalidConversion')
    info = [' This failure occured because the conversion function for the metadata did not produce ',...
        'a valid metadata matrix.'];
elseif contains(id, 'metadataSizeConflict')
    info = ' This failure occured because the output of the metadata conversion function has the wrong number of rows.';
else
    info = '';
end

% Create error
id = cause.identifier;
ME = MException(id, ['Cannot build an ensemble for %s because metadata ',...
    'for the "%s" dimension of the "%s" variable failed to load.%s'],...
    obj.name, dim, obj.variables(v), info);
ME = addCause(ME, cause.cause{1});

end
function[] = incompatibleMetadataFormatsError(obj, vars, v, dim, metadata, varMetadata, header)

v1 = vars(1);
v2 = vars(v);

if size(metadata,2)~=size(varMetadata,2)
    info = sprintf(['The metadata is not compatible because the metadata for "%s" ',...
        'has %.f columns, while the metadata for "%s" has %.f columns.'],...
        obj.variables(v1), size(metadata,2), obj.variables(v2), size(varMetadata,2));
else
    info = sprintf(['The metadata is not compatible because the metadata for "%s" ',...
        'is a "%s" data type, while the metadata for "%s" is a "%s" data type. ',...
        'Compatible data types are (numeric/logical), (char/string/cellstring), and (datetime).'],...
        obj.variables(v1), class(metadata), obj.variables(2), class(varMetadata));
end

link1 = '<a href="matlab:dash.doc(''stateVector.getMetadata'')">stateVector.getMetadata</a>';
link2 = '<a href="matlab:dash.doc(''stateVector.metadata'')">stateVector.metadata</a>';

id = sprintf('%s:incompatibleMetadata', header);
ME = MException(id, ['Cannot build an ensemble for %s because variables "%s" and "%s" ',...
    'are coupled, but do not have compatible metadata along the "%s" ',...
    'dimension. %s\n\nYou may need to adjust the metadata for the variables. ',...
    'You can use the %s method to return the metadata for a variable, and the ',...
    '%s method to adjust a variable''s metadata.'],...
    obj.name, obj.variables(v1), obj.variables(v2), dim, info, link1, link2);
throwAsCaller(ME);
end
function[] = noMatchingMetadataError(obj, vars, dim, header)

link1 = '<a href="matlab:dash.doc(''stateVector.getMetadata'')">stateVector.getMetadata</a>';
link2 = '<a href="matlab:dash.doc(''stateVector.metadata'')">stateVector.metadata</a>';

vars = obj.variables(vars);
id = sprintf('%s:noMatchingMetadata', header);
ME = MException(id, ['Cannot build an ensemble for %s. The variables %s are ',...
    'coupled, but there is no matching metadata across all the variables over ',...
    'the "%s" dimension.\n\nYou may need to adjust the metadata for some of ',...
    'the variables. See the %s method to return the metadata for a variable ',...
    'and the %s method to adjust a variable''s metadata.'],...
    obj.name, dash.string.list(vars), dim, link1, link2);
throwAsCaller(ME);
end
function[] = tooBigToLoadWarning(file)
link = '<a href="matlab:dash.doc(''ensemble'')">ensemble class</a>';
[~,name] = fileparts(file);
name = strcat(name,".ens");
warning(['The state vector ensemble was successfully written to file "%s". ',...
    'However, the ensemble is too large to fit in active memory, so cannot ',...
    'be returned directly as output. Use the %s class to interact with the ',...
    'saved ensemble instead.'], name, link);
end