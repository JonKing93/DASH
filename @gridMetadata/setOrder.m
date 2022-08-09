function[obj] = setOrder(obj, varargin)
%% gridMetadata.setOrder  Specify a dimension order for a gridded dataset
% ----------
%   obj = <strong>obj.setOrder</strong>(dimensions)
%   Specifies an order of dimensions. Dimension order can be accessed via
%   the .order property of a gridMetadata object. Dimensions are listed in
%   this order when the gridMetadata object is displayed in the console.
%   The dimension order will be deleted if the defined dimensions
%   (dimension with metadata) change for the gridMetadata object.
%
%   obj = <strong>obj.setOrder</strong>(dimension1, dimension2, .., dimensionN)
%   Specify dimension order by listing dimensions as inputs, rather than as
%   a string list.
%
%   obj = <strong>obj.setOrder</strong>(0)
%   Removes the dimension order (if it exists) from the current
%   gridMetadata object.
% ----------
%   Inputs:
%       dimensions (string vector): The order of dimensions for the
%           gridMetadata object. Can only include the names of defined
%           dimensions (those with metadata), and must list each defined
%           dimension exactly once.
%       dimensionN (string scalar): The name of a defined dimension in the
%           gridMetadata object. The input dimension names must list each
%           defined dimension exactly once.
%
%   Outputs:
%       obj (gridMetadata object): The updated gridMetadata object. When
%           displayed in the console, dimensions are listed in the
%           specified order. The dimension order can also be returned via
%           the .order property.
%
% <a href="matlab:dash.doc('gridMetadata.setOrder')">Documentation Page</a>

% Header
header = "DASH:gridMetadata:setOrder";
dash.assert.scalarObj(obj, header);

% Parse dimension lists
if numel(varargin)==0
    dash.error.notEnoughInputs;
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

% Error message
function[] = missingDimensionError(dims, loc, header)
id = sprintf('%s:missingDimension', header);
missing = find(loc==0, 1);
missing = dims(missing);
ME = MException(id, 'The dimension order must include the "%s" dimension', missing);
throwAsCaller(ME);
end