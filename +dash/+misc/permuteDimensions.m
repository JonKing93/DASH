function[X, order] = permuteDimensions(X, index, iscomplete, nDims)
%% Permutes dimensions of an array to match a requested order. There are 
% two common use cases.
%
% Case 1: The array has the complete set of dimensions and should be
%    permuted to match a custom order. The custom order might only include
%    a subset of all possible dimensions.
%
% Case 2: The array is in a custom order and might only hold a subset of all
%    possible dimensions. We want to permute the array to fill the complete
%    set of dimensions.
%
% [X, order] = dash.permuteDimensions(X, index, iscomplete, nDims)
%
% ----- Inputs -----
%
% X: The array
%
% index: The locations of the custom ordered dimensions in the complete set
%    of dimensions. Usually generated via something like:
%    >> [~, index] = ismember( customDims, allDims )
%
% iscomplete: A scalar logical indicating whether the input array has the
%    complete set of dimensions in order. Use true for case 1 and false for
%    case 2.
%
% nDims: The number of dimensions in the complete set of dimensions
%
% ----- Output -----
%
% X: The permuted array
%
% order: The permutation order used to permute X.

% Get the order of the subset dimensions in the complete array
d = 1:nDims;
if ~isrow(index)
    index = index';
end
order = [index, d(~ismember(d, index))];

% Case 1, the current dimension order is the complete array.
% In this case we are done. The order will map the complete array to the
% subset.

% Case 2, the current dimension order is a subset of the complete array.
if ~iscomplete
    [~, order] = sort(order);
end

% Permute the array
X = permute(X, order);

end