function[X, meta, obj] = addMembers(obj, nMembers)
%% stateVector.addMembers  Add more ensemble members to an existing state vector ensemble
% ----------
%   [X, metadata, obj] = obj.addMembers(nMembers)
%   Adds the specified number of ensemble members to an existing ensemble
%   and returns the additional ensemble members as output. Also returns the
%   ensembleMetadata object for the new ensemble members. (Note that the
%   ensemble metadata does not include metadata for previously built
%   ensemble members). The third output is the state vector object for the
%   built ensemble. It includes information on any previously built
%   ensemble members, as well as the newly built ensemble members and can
%   be used to add more members to the ensemble if necessary.
%
%   **Note**: This method cannot be used to add more ensemble members to an
%   ensemble stored in a .ens file. If this is your objective, see the
%   method "ensemble.addMembers" instead.
%
%   ... = obj.addMembers('all')
%   Adds as many new ensemble members as possible to the existing ensemble.
%   Reports the number of ensemble members being built to the console.
%
%   ... = obj.addMembers(..., 'showprogress', true|false
%   ... = obj.addMembers(..., 'showprogres', showprogress)
%   Specify whether to display a progress bar. Default is to not display a
%   progress bar.
%
%   ... = obj.addMembers(..., 'strict', true|false)
%   ... = obj.addMembers(..., 'strict', strict)
%   Specify how the method should respond if it cannot build the requested
%   number of ensemble members. If true (default), throws an error when the
%   requested number of ensemble members cannot be built. If false, issues
%   a warning (but does not fail) when the requested number of ensemble
%   members cannot be built. If this occurs, the output ensemble will have
%   fewer columns than the requested number of ensemble members.
%
%   ... = obj.addMembers(..., 'precision', 'single'|'double')
%   ... = obj.addMembers(..., 'precision', precision)
%   Specify the numerical precision of the new ensemble members. If no
%   precision is specified, selects a precision based on the precision of
%   the data used to build the ensemble.
% ----------
%   Inputs:
%       nMembers (scalar positive integer | 'all'): The number of ensemble
%           members (columns) that should be in the built ensemble. Use
%           'all' to use every possible ensemble member.
%       strict (scalar logical): Specify how the method should respond if
%           the requested number of ensemble members cannot be built. If
%           true (default), throws an error. If false, issues a warning and
%           returns an ensemble with however many ensemble members did
%           successfully build.
%       precision ('single' | 'double'): The desired numerical precision of
%           the built state vector ensemble.
%
%   Outputs:
%       X (numeric matrix [nState x nMembers]): The new ensemble members
%           for the state vector ensemble. Has one row per state vector
%           element. Each column holds one new ensemble member.
%       metadata (scalar ensembleMetadata object): An ensemble metadata
%           object for the new ensemble members. Organizes metadata along
%           the rows and columns of the ensemble.
%       obj (scalar stateVector object): The state vector object for the
%           built ensemble. Can be used to add additional members to the
%           ensemble. Cannot be edited in any way.
%
% <a href="matlab:dash.doc('stateVector.addMembers')">Documentation Page</a>

%% Error check

% Setup, redirect to build if unbuilt
header = "DASH:stateVector:addMembers";
dash.assert.scalarObj(obj, header);
if obj.iseditable
    buildError(obj, header);
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
flags =    ["strict","precision","showprogress", "file", "overwrite"];
defaults = {  true,    [],         false,          [],        []    };
[strict, precision, showprogress] = dash.parse.nameValue(...
                                 varargin, flags, defaults, 1, header);

% Redirect user if attempting to write to file
if ~isempty(file)
    fileError;
end
if ~isempty(overwrite)
    overwriteError;
end

% Error check optional inputs
dash.assert.scalarType(strict, 'logical', 'strict', header);
dash.assert.scalarType(showprogress, 'logical', 'showprogress', header);
if ~isempty(precision)
    precision = dash.assert.strflag(precision, 'precision', header);
    dash.assert.strsInList(precision, ["single","double"], 'precision', 'recognized option', header);
end

% Initialize progress bar
if showprogress
    progress = progressbar;
else
    progress = [];
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

%% Build ensemble

ens = [];
coupling = obj.couplingInfo;
[X, meta, obj] = obj.buildEnsemble(ens, nMembers, strict, grids, coupling, precision, progress);

end