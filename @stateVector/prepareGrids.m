function[grids, failed, cause] = prepareGrids(obj, header)
%% stateVector.prepareGrids  Build and validate gridfile objects for variables in a state vector
% ----------
%   [grids, failed, cause] = <strong>obj.prepareGrids</strong>(header)
%   Builds and validate the gridfile objects saved for the variables
%   currently in the state vector. If successful, returns the unique
%   gridfile objects for the set of variables. If failed, returns the index
%   of the failed gridfile and the cause of the failure.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs.
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
% <a href="matlab:dash.doc('stateVector.prepareGrids')">Documentation Page</a>

% Default
if ~exist('header','var')
    header = "DASH:stateVector:prepareGrids";
end

% Object assertions
dash.assert.scalarObj(obj, header);
obj.assertUnserialized;

% Build gridfiles from the saved file paths
[grids, failed, cause] = stateVector.buildGrids(obj.gridfiles);

% Check gridfiles match recorded values
if ~failed
    vars = 1:obj.nVariables;
    [failed, cause] = obj.validateGrids(grids, vars, header);
    if failed
        grids = [];
    end
end

end