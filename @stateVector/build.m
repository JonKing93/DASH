function[X, meta, obj] = build(obj, nMembers, varargin)
%% stateVector.build  Build a state vector ensemble
% ----------
%   [X, metadata, obj] = obj.build(nMembers)
%   Builds a state vector ensemble with the specified number of ensemble
%   members and returns the ensemble as output. The built ensemble is a
%   matrix with one column per ensemble member. As the second output, the
%   method returns an ensembleMetadata object, which organizes metadata
%   along the rows and columns of the ensemble. The final output is the
%   state vector object for the built ensemble, which can be used to add
%   additional members to the ensemble if necessary.
%
%   ... = obj.build('all')
%   Builds a state vector ensemble with as many ensemble members as
%   possible.
%
%   obj.build(..., 'sequential', true | false)
%   obj.build(..., 'sequential', buildSequentially)
%   Specify whether ensemble members should be selected sequentially along
%   the ensemble dimensions, or at random. The default behavior is random
%   selection. Use this option if, for example, you want the ensemble
%   members to remain ordered in time.
%
%   obj.build(..., 'file', filename)
%   Saves the state vector ensemble to a .ens file of the specified name.
%   The saved ensemble can then be accessed at any time using the
%   "ensemble" class. This option allows you to build ensembles that are
%   too large to fit in active memory.
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
%
%   Outputs:
%       X (numeric matrix [nState x nMembers]): The built state vector
%           ensemble. Has one row per state vector element. Each column is
%           an ensemble member.
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

% Error check members
if dash.is.string(nMembers)
    nMembers = string(nMembers);
end
dash.assert.scalarType(nMembers, ["string","numeric"], 'nMembers', header);
if isnumeric(nMembers)
    dash.assert.positiveIntegers(nMembers, 'Since it is numeric, nMembers', header);
elseif ~strcmp(nMembers, "all")
    id = sprintf("%s:invalidMembers", header);
    error(id, 'nMembers must either be a scalar positive integer, or "all".');
end

% Parse the other variables
flags =    ["sequential","file","overwrite","showprogress"];
defaults = {    false,        [],     false,        false    };
[sequential, filename, overwrite, showprogress] = dash.parse.nameValue(...
    varargin, flags, defaults, 1, header);

% Error check logical switches
dash.assert.scalarType(sequential, 'logical', 'buildSequentially', header);
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


%% Build gridfiles

% Get the unique set of gridfiles. Note which grid is used by each variable
[grids, ~, whichGrid] = unique(obj.gridfiles);

% Build each gridfile, informative error if failed
[grids, failed, cause] = obj.buildGrids(grids);
if failed
    couldNotBuildGridfileError(obj, grids, whichGrid, failed, cause)
end

% Validate the grids against each variable
for v = 1:obj.nVariables
    grid = grids( whichGrid(v) );
    [isvalid, cause] = obj.variables_(v).validateGrid(grid);
    if ~isvalid
        invalidGridfileError(obj, v, grid, cause);
    end
end


%% Select ensemble members

% Trim ensemble dimensions to only allow complete sequences and means
for v = 1:obj.nVariables
    obj.variables_(v) = obj.variables_(v).trim;
end

% Get sets of coupled variables
coupledSets = unique(obj.coupled, 'rows');
nSets = size(coupledSets, 1);

% Preallocate unused, and selected ensemble members
obj.unused = cell(nSets, 1);
obj.members = cell(nSets, 1);

% Cycle through sets of coupled variables
for s = 1:nSets
    vars = find(coupledSets(s,:));
    varGrids = grids(whichGrid(vars));
    nCoupledVars = numel(vars);

    % Get a reference variable and the indices of ensemble dimensions
    variable1 = obj.variables_(vars(1));
    ensDims = variable1.dimensions('ensemble');
    dims = obj.dimensionIndices(v, ensDims, header);

    % Cycle through ensemble dimensions. Get the metadata intersect over
    % all the coupled variables
    for d = 1:numel(ensDims)
        metadata = getMetadata(vars(1), dims(1,d), varGrids(1), header);
        for v = 2:nCoupledVars
            varMetadata = getMetadata(vars(v), dims(v,d), varGrids(v), ensDims(d), header);
            try
                metadata = intersect(metadata, varMetadata, 'rows', 'stable');
            catch ME
                incompatibleMetadataFormatsError;
            end

            % Throw error if there is no overlapping metadata
            if isempty(metadata)
                noMatchingMetadataError;
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
    nUnused = obj.variables_(vars(1)).nMembers;
    if sequential
        unused = (1:nUnused)';
    else
        unused = randperm(nUnused)';
    end
    obj.unused{s} = unused;
end


%% Build / Write ensemble

% Use an empty array if not writing file
ens = [];

% Otherwise, use a temporary file to hold the incomplete ensemble
if writeFile
    tmpFile = strcat(filename, ".tmp");

    % Always delete the .tmp file 
    cleanup = onCleanup(@()removeTmpFile(tmpFile));

    % Intialize the new matfile
    removeTmpFile(tmpFile);
    ens = matfile(tmpFile);
end

% Build the ensemble.
obj.editable = false;
[X, meta, obj] = obj.buildEnsemble(nMembers, grids, ens, showprogress);

% If writing, optionally return output array
if writeFile
    if nargout>0
        try
            X = ens.X;   
        catch
            tooBigToLoadWarning(filename);
        end
    end

    % Move data from .tmp to .ens - Do this *after* attempting to load so
    % that the matfile (ens) remains valid.
    movefile(tmpFile, filename);
end

end


% Utility functions
function[metadata] = getMetadata(obj, v, d, grid, dim, header)

% Get the metadata for the dimension
variable = obj.variables_(v);
[metadata, failed, cause] = variable.getMetadata(d, grid, header);

% Informative error if failed
if failed
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
ME = MException(id, ['You cannot build an ensemble for %s because the "%s" variable ',...
    'does not have any ensemble dimensions. See %s to set ensemble dimensions ',...
    'for the variable.'], obj.name, var, link);
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

function[] = tooBigToLoadWarning(file)
link = '<a href="matlab:dash.doc(''ensemble'')">ensemble class</a>';
[~,name] = fileparts(file);
name = strcat(name,".ens");
warning(['The state vector ensemble was successfully written to file "%s". ',...
    'However, the ensemble is too large to fit in active memory, so cannot ',...
    'be returned directly as output. Use the %s class to interact with the ',...
    'saved ensemble instead.'], name, link);
end