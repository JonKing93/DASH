function[dims] = dimensions(obj, varNames, type)
%% Displays the names of dimensions in specified variables
%
% obj.dimensions
% Prints a list of the dimensions in each variable to the console.
%
% obj.dimensions(varNames)
% Prints a list of dimensions for the specified variables to the console.
%
% obj.dimensions(varNames, type)
% Prints a list of state dimensions, ensemble dimensions, or all
% dimensions, as requested.
%
% [dims] = obj.dimensions(...)
% Returns the lists of dimensions as a structure array. Does not print to
% console.
%
% ----- Inputs -----
%
% varNames: The names of the variables for which to return dimension names.
%    A string vector or cellstring vector.
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

% Default, error check variable names
if ~exist('varNames','var') || isempty(varNames)
    v = 1:numel(obj.variables);
else
    v = obj.checkVariables(varNames);
end
nVars = numel(v);

% Default, error check type
flags = ["state","s","ensemble","ens","e","all","a"];
if ~exist('type','var') || isempty(type)
    type = 'all';
elseif ~any(strcmpi(type, flags))
    error('type must be one of the following strings: %s', dash.messageList(flags));
end
type = lower(type);

% Console output
if nargout==0 && nVars>0
    fprintf('\n');
    for k = 1:nVars
        obj.variables(v(k)).dimensions(type);
    end
    fprintf('\n');
    
% Preallocate structure output
elseif nargout~=0
    field = "dimensions";
    if ismember(type, ["state","s"])
        field = "stateDimensions";
    elseif ismember(type, ["ensemble","ens","e"])
        field = "ensembleDimensions";
    end
    dims = repmat( struct(field, []), [nVars, 1]);
    
    % Build output structure
    for k = 1:nVars
        dims(k).(field) = obj.variables(v(k)).dimensions(type);
    end
end

end