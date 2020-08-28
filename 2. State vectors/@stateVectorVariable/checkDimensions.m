function[d, dims] = checkDimensions(obj, dims)
%% Returns the indices of dimensions in a state vector variable. Returns an
% error if any dimensions do not exist. Does not allow duplicate names.
% Also returns the dimension names as strings
%
% [d, dims] = obj.checkDimensions(dims)
%
% ----- Inputs -----
%
% dims: The input being checked as a list of dimension names.
%
% ----- Outputs -----
%
% d: The indices in the stateVectorVariable dims array
%
% dims: The dimension names as strings

% Option for empty dims
d = [];
if ~isempty(dims)

    % Check the dimensions are in the variable and get their index
    listName = sprintf('dimension in the .grid file for the %s variable', obj.name);
    d = dash.checkStrsInList(dims, obj.dims, 'dims', listName);

    % No duplicates
    if numel(d) ~= numel(unique(d))
        error('dims cannot repeat dimension names.');
    end
    
    % Convert dims to string
    dims = string(dims);
end

end