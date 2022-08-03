function[isvalid, cause] = validateGrid(obj, grid, header)
%% dash.stateVectorVariable.validateGrid  Check that a gridfile object matches a variable's recorded gridfile parameters
% ----------
%   [isvalid, cause] = <strong>obj.validateGrid</strong>(grid)
%   Checks that a gridfile object matches the gridfile parameters recorded
%   for a state vector variable. If the object does not match the
%   parameters, returns false and the cause of the mismatch as an MException. 
%   If the object matches, returns true and an empty array.
%
%   [isvalid, cause] = <strong>obj.validateGrid</strong>(grid, header)
%   Customize the header of returned MExceptions.
% ----------
%   Inputs:
%       grid (scalar gridfile object): The gridfile object being compared
%           to the variable's recorded gridfile parameters.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       isvalid (scalar logical): True is the gridfile object matches the
%           recorded values. False if not.
%       cause ([] | scalar MException): If the gridfile does not match the
%           recorded values, an MException reporting the cause of the mismatch.
%           If the grid matches recorded values, an empty array.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.validateGrid')">Documentation Page</a>

% Default
if ~exist('header','var')
    header = "DASH:stateVectorVariable:validateGrid";
end

% Initialize
isvalid = true;
cause = [];

% Check dimensions are the same
if ~isequal(obj.dims, grid.dims)
    id = sprintf('%s:changedGridfileDimensions', header);
    cause = MException(id, ...
        ['The recorded gridfile dimensions (%s) do not match\n' ...
        'the dimensions of the new gridfile (%s).'], ...
        dash.string.list(obj.dims), dash.string.list(grid.dims));
    isvalid = false;

% Check sizes are the same
elseif ~isequal(obj.gridSize, grid.size)
    id = sprintf('%s:changedGridfileSize', header);
    cause = MException(id, ...
        ['The recorded gridfile size (%s) does not match\n' ...
        'the size of the new gridfile (%s).'], ...
        dash.string.size(obj.gridSize), dash.string.size(grid.size));
    isvalid = false;
end

end