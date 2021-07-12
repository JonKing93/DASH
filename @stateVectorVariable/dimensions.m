function[dims] = dimensions(obj, type)
%% Displays the dimensions of a variable.
%
% obj.dimensions(type)
% Prints a list of state dimensions, ensemble dimensions, or all
% dimensions, as requested.
%
% [dims] = obj.dimensions(type)
% Returns the dimensions as a string vector. Does not print to console.
%
% ----- Inputs -----
%
% type: A string scalar or character row vector indicating which dimensions
%    to return.
%    'state' / 's': Return state dimensions
%    'ensemble' / 'ens' / 'e': Return ensemble dimensions
%    'all' / 'a': Return all dimensions
%
% ----- Outputs -----
%
% dims: A string vector containing the names of the requested dimensions

% Only use non-singleton grid dimensions
dims = obj.dims(obj.gridSize>1);
isState = obj.isState(obj.gridSize>1);

% Get the dims and string for different dimensions
str = "D";
if ismember(type, ["state","s"])
    dims = dims(isState);
    str = "State d";
elseif ismember(type, ["ensemble","ens","e"])
    dims = dims(~isState);
    str = "Ensemble d";
end

% Console output
if nargout==0
    fprintf('%simensions for variable "%s": %s\n', str, obj.name, dash.string.messageList(dims));
end

end