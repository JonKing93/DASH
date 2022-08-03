function[dimensions] = dimensions(obj, type)
%% dash.stateVectorVariable.dimensions  List the dimensions of a state vector variable
% ----------
%   dimensions = <strong>obj.dimensions</strong>
%   dimensions = <strong>obj.dimensions</strong>('all')
%   Return the list of all dimensions in the variable, as well as the number
%   of state vector elements associated with each dimension.
%
%   dimensions = <strong>obj.dimensions</strong>('state')
%   Return the list of state dimensions for the variable.
%
%   dimensions = <strong>obj.dimensions</strong>('ensemble')
%   Return the list of ensemble dimensions for the variable.
% ----------
%   Outputs:
%       dimensions (string vector [nDimensions]): The list of dimensions of the requested
%           type for the variable.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.dimensions')">Documentation Page</a>

% Default
if ~exist('type','var') || isempty(type)
    type = 'all';
end

% Select dimensions
if strcmp(type, 'all')
    use = 1:numel(obj.dims);
elseif strcmp(type, 'state')
    use = obj.isState;
elseif strcmp(type, 'ensemble')
    use = ~obj.isState;
end

% Get names
dimensions = obj.dims(use);

end

