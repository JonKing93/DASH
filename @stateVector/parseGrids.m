function[grids, failed, cause] = parseGrids(grids, nVariables, header)
%% stateVector.parseGrids  Parse inputs that are either gridfile objects or .grid file paths
% ----------
%   [grids, failed, cause] = stateVector.parseGrids(grids, nVariables)
%   Parses gridfile inputs for a specified number of variables. If inputs
%   are strings, returns the unique set of gridfile objects. If inputs are
%   gridfile objects, updates the objects and returns them directly.
%
%   gridfile inputs may either be a scalar or a vector with one element per
%   specified variable. Regardless of input type, the output parsed grids
%   include "whichGrid" indices that specify which gridfile object should
%   be used for each listed variable.
% 
%   If any gridfile fails to build or update, records the failed gridfile
%   and exits.
%
%   ... = stateVector.parseGrids(grids, nVariables, header)
%   Customize header in thrown error IDs.
% ----------
%   Inputs:
%       grids: The input being parsed. If valid, should be a string or gridfile
%           scalar, or a vector with one element per variable.
%       nVariables (scalar positive integer): The number of variables that
%           the gridfile input is for.
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       grids (scalar struct): Organized set of gridfile objects
%           .gridfiles (gridfile vector [nGrids]): The gridfile objects
%           .whichGrid (vector, linear indices [nVariables]): The index of
%               the gridfile object for each variable. Indices are on the
%               interval 1:nGrids
%
% <a href="matlab:dash.doc('stateVector.parseGrids')">Documentation Page</a>

% Default header
if ~exist('header','var') || isempty(header)
    header = "DASH:stateVector:parseGrids";
end

% Use strings for text. Require string or gridfile type
if dash.is.string(grids)
    grids = string(grids);
end
try
    dash.assert.type(grids, ["string","gridfile"], 'grids', [], header);
catch ME
    throwAsCaller(ME);
end

% Get the number of grids. Require correct length if not scalar. Get
% whichGrid for either case.
nGrids = numel(grids);
if nGrids==1
    whichGrid = ones(nVariables, 1);
else
    whichGrid = (1:nVariables)';

    name = 'Since it is not scalar, grids';
    try
        dash.assert.vectorTypeN(grids, [], nVariables, name, header);
    catch ME
        throwAsCaller(ME);
    end
end

% If given string filepaths, build gridfile objects and exit
if isstring(grids)
    [grids, failed, cause] = stateVector.buildGrids(grids);
    if ~failed && nGrids==1
        grids.whichGrid = whichGrid;
    end
    return
end

% If given gridfile objects, attempt to update each object
try
    for g = 1:nGrids
        if ~isvalid( grids(g) )
            id = sprintf('%s:deletedGridfile', header);
            error(id, 'The gridfile object has been deleted.');
        end
        grids(g).update;
    end

% Capture and report DASH errors
catch cause
    if ~contains(cause.identifier, "DASH")
        rethrow(cause);
    end
    grids = [];
    failed = g;
    return
end

% Organize output
grids = struct('gridfiles', grids(:), 'whichGrid', whichGrid);
failed = 0;
cause = [];

end