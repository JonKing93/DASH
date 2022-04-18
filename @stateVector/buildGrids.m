function[grids, failed, cause] = buildGrids(files)
%% stateVector.buildGrids  Build unique gridfile objects
% ----------
%   [grids, failed, cause] = stateVector.buildGrids(files)
%   Builds the unique set of gridfile objects for the specified filepaths.
%   Returns a structure that includes the unique gridfile objects, and the
%   index of the object associated with each element of "files". If any
%   gridfile fails to build, reports the failed grid and the cause of the
%   failure.
% ----------
%   Inputs:
%       files (string vector [nVariables] | string scalar): The absolute
%           file paths to a set of gridfiles
%
%   Outputs:
%       grids (scalar struct): Organizes the gridfile objects
%           .gridfiles (gridfile vector [nGrids]): The unique gridfile objects
%           .whichGrid (vector, linear indices [nVariables]): The index of
%               the unique gridfile object associated with each input filepath.
%               Indices are on the interval 1:nGrids
%       failed (0 | scalar linear index): Set to 0 if all gridfiles built
%           successfully. If not, the index of the first failed file path.
%           Index is on the interval 1:nFiles
%       cause (scalar MException): The cause of the failed gridfile
%
% <a href="matlab:dash.doc('stateVector.buildGrids')">Documentation Page</a>

% Get the unique file paths. Preallocate gridfile objects
[files, ~, whichGrid] = unique(files);
nGrids = numel(files);
gridObjects = cell(nGrids, 1);

% Build each gridfile
try
    for g = 1:nGrids
        gridObjects{g} = gridfile(files(g));
    end

% Capture and report DASH errors
catch cause
    if ~contains(cause.identifier, "DASH")
        rethrow(cause);
    end
    failed = find(whichGrid==g,1);
    grids = [];
    return
end

% Organize output
gridObjects = [gridObjects{:}]';
grids = struct('gridfiles', gridObjects, 'whichGrid', whichGrid);
failed = 0;
cause = [];

end