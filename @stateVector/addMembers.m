function[X, meta, obj] = addMembers(obj, nMembers)
%
% obj.addMembers(nMembers)
%
% obj.addMembers(..., 'strict', strict)
%
% obj.addMembers(..., 'precision', precision)
%
% obj.addMembers(..., 'showprogress', showprogress)
%

%% Error check

% Setup, redirect to build if unbuilt
header = "DASH:stateVector:addMembers";
dash.assert.scalarObj(obj, header);
if obj.iseditable
    buildError(obj, header);
end
obj.assertUnserialized;

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
flags =    ["sequential","strict","showprogress","file","overwrite"];
defaults = {    false,     true,     false,       [],        []    };
[sequential, strict, showprogress, file, overwrite] = dash.parse.nameValue(...
                                 varargin, flags, defaults, 1, header);

% Redirect user if attempting to write to file
if ~isempty(file)
    fileError;
end
if ~isempty(overwrite)
    overwriteError;
end

% Error check logical switches
dash.assert.scalarType(sequential, 'logical', 'buildSequentially', header);
dash.assert.scalarType(strict, 'logical', 'strict', header);
dash.assert.scalarType(showprogress, 'logical', 'showprogress', header);


%% Setup

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

% Get coupling info
coupling = obj.couplingInfo;


%% Load


