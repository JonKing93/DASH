function[limits] = limits(nElements)
%% dash.indices.limits  Returns index limits given a set of element counts
% ----------
%   limits = dash.indices.limits(nElements)
%   Given a set of element counts, returns the index limits of the item
%   associated with each set of elements.
% ----------
%   Inputs:
%       nElements (vector, positive integers [nSets]): The number of
%           elements associated with each set of values.
%
%   Outputs:
%       limits (matrix, positive integers [nSets x 2]): The index limits of
%           each set of elements in the full set of values.
%
% <a href="matlab:dash.doc('dash.indices.limits')">Documentation Page</a>

% Use a column vector
if isrow(nElements)
    nElements = nElements';
end

% Get the limits
last = cumsum(nElements);
first = [1; last(1:end-1)+1];
limits = [first, last];

end