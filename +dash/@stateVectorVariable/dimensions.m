function[dimensions] = dimensions(obj, type)
%% dash.stateVectorVariable.dimensions  List the dimensions of a state vector variable
% ----------
%   dimensions = obj.dimensions
%   dimensions = obj.dimensions('all')
%   Return the list of all dimensions in the variable.
%
%   dimensions = obj.dimensions('state')
%   Return the list of state dimensions.
%
%   dimensions = obj.dimensions('ensemble')
%   Return the list of ensemble dimensions.
% ----------
%   Outputs:
%       dimensions (string list): The list of dimensions of the requested
%           type for the variable.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.dimensions')">Documentation Page</a>

% Get dimensions
dimensions = obj.dims;

% Refine by type
if strcmp(type, 'state')
    dimensions = dimensions(obj.isState);
elseif strcmp(type, 'ensemble')
    dimensions = dimensions(~obj.isState);
end

end

