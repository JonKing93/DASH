function[dimensions] = dimensions(obj, type)
%% dash.stateVectorVariable.dimensions  List the dimensions of a state vector variable
% ----------
%   dimensions = <strong>obj.dimensions</strong>
%   Return the list of all dimensions in the variable.
%
%   dimensions = <strong>obj.dimensions</strong>(type)
%   dimensions = <strong>obj.dimensions</strong>('all' | 'state' | 'ensemble')
%   Return a list of dimension of a specific type. If 'all', returns the
%   list of all dimensions in the variable. If 'state', returns the list of
%   state dimensions for the variable. If 'ensemble', returns the list of
%   ensemble dimensions for the variable.
% ----------
%   Inputs:
%       type (string scalar): Indicates the type of dimensions to return
%           ['all' (default]: Return all dimensions for the variable
%           ['state']: Return the state dimensions for the variable
%           ['ensemble']: Return the ensemble dimensions for the variable
%   
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

