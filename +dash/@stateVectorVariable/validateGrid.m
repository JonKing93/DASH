function[] = validateGrid(obj, grid, header)
%% dash.stateVectorVariable.validateGrid  Check that a gridfile object matches a variable's recorded gridfile parameters
% ----------
%   obj.validateGrid(grid)
%   Checks that a gridfile object matches the gridfile parameters recorded
%   for a state vector variable. Throws an error if not.
% ----------
%   Inputs:
%       grid (scalar gridfile object): The gridfile object being compared
%           to the variable's recorded gridfile parameters.
%       header (string scalar): Header for thrown error IDs.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.validateGrid')">Documentation Page</a>

% Default
if ~exist('header','var')
    header = "DASH:stateVectorVariable:verifyGrid";
end

% Check dimensions are the same
if ~isequal(obj.dims, grid.dims)
    id = sprintf('%s:changedGridfileDimensions', header);
    error(id, ['The recorded gridfile dimensions (%s) do not match the dimensions ',...
        'of the current gridfile (%s). The gridfile may have been altered ',...
        'after the variable was added to the state vector.\n\ngridfile: %s'], ...
        dash.string.list(obj.dims), dash.string.list(grid.dims), obj.file);

% Check sizes are the same
elseif ~isequal(obj.gridSize, grid.size)
    id = sprintf('%s:changedGridfileSize', header);
    error(id, ['The recorded gridfile size (%s) does not match the size of ',...
        'the current gridfile (%s). The gridfile may have been altered after ',...
        'the variable was added to the state vector.\n\ngridfile: %s'], ...
        dash.string.size(obj.gridSize), dash.string.size(grid.size), grid.file);
end

end