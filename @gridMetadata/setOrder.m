function[obj] = setOrder(obj, varargin)
%% Specifies an order for gridMetadata dimensions


% Header
header = "DASH:gridMetadata:setOrder";

% Parse dimension lists
if numel(varargin)==0
    error('MATLAB:minrhs', 'Not enough input arguments');
elseif numel(varargin)==1 && isequal(varargin{1}, 0)
    obj.order = strings(1,0);
    return
elseif numel(varargin)==1
    order = dash.assert.strlist(varargin{1}, 'dimensions', header);
else
    order = dash.parse.vararginFlags(varargin, 1, 0, header);
end

% Require all and only defined dimensions
dims = obj.defined;
dash.assert.strsInList(order, dims, 'dimension name', 'defined dimension', header);
[inInput, loc] = ismember(dims, order);
if ~all(inInput)
    missingDimensionError(dims, loc, header);
end

% Use a row vector
if ~isrow(order)
    order = order';
end

% Record the order
obj.order = order;

end