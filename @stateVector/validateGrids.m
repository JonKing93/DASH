function[failed, cause] = validateGrids(obj, grids, vars, header)
%% stateVector.validateGrids  Check that gridfiles match values recorded for variables in a state vector
% ----------
%   [failed, cause] = obj.validateGrids(grids, vars)
%   Checks if the provided gridfile objects match the gridfile parameters
%   recorded for specified variables in a state vector. If not, returns the
%   index of the first failed variable and reports the cause of the
%   failure.
% ----------
%   Inputs:
%       grids (scalar struct): Organizes a set of unique gridfile objects
%           .gridfiles (gridfile vector [nGrids]): The unique gridfile objects
%           .whichGrid (vector, linear indices [nVariables]): The index of
%               the unique gridfile object associated with each input
%               variable. Indices are on the interval 1:nGrids
%       vars (vector, linear indices [nVariables]): The index of the variables
%           for the gridfile objects within the set of state vector variables
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       failed (0 | scalar linear index): Set to 0 if the gridfile objects
%           are all valid. If not, returns the state vector variable index
%           of the first failed variable.
%       cause (scalar MException): The cause of the failed variable
%
% <a href="matlab:dash.doc('stateVector.validateGrids')">Documentation Page</a>

% Cycle through state vector variables
for k = 1:numel(vars)
    v = vars(k);
    variable = obj.variables_(v);

    % Get the associated gridfile
    g = grids.whichGrid(k);
    grid = grids.gridfiles(g);

    % Check validity. Exit if any are invalid
    [isvalid, cause] = variable.validateGrid(grid, header);
    if ~isvalid
        failed = v;
        return;
    end
end

% Success
failed = 0;
cause = [];

end