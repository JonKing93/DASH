function[subscriptIndices] = subscript(siz, linearIndices)
%% dash.indices.subscript  Convert linear indices to N-dimensional subscripts
% ----------
%   subscriptIndices = dash.indices.subscript(siz)
%   Given the size of an array in N-dimensions, returns the subscript
%   indices for each element in the array along each dimension. The number
%   of subscripted dimensions will match the number of elements in the
%   first input.
%
%   subscriptIndices = dash.indices.subscript(siz, linearIndices)
%   Returns subscript indices for the specified linear indices in the
%   array, rather than for all elements in the array. The number of
%   subscript indices for each dimension will match the number of input
%   linear indices.
% ----------
%   Inputs:
%       siz (row vector, positive integers [nDimensions]): The size of an
%           N-dimensional array
%       linearIndices (vector, positive integers): The linear indices for
%           which to return subscript indices.
%
%   Outputs:
%       subscriptIndices (cell vector [nDimensions] {linear subscript indices}:
%           Subscript indices for elements in the array. If no linear
%           indices are specified, includes the subscript indices for each
%           array element in order. If linear indices are provided,
%           includes subscript indices for each listed linear index.
%
% <a href="matlab:dash.doc('dash.indices.subscript')">Documenation Page</a>

% Default is all linear indices. Use column vector of linear indices
if ~exist('linearIndices','var')
    linearIndices = 1:prod(siz);
end
if isrow(linearIndices)
    linearIndices = linearIndices';
end

% Preallocate subscript cells
nDims = numel(siz);
subscriptIndices = cell(1, nDims);

% Collect subscripts in all dimensions
[subscriptIndices{:}] = ind2sub(siz, linearIndices);

end

