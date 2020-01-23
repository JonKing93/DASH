function[X, file, var, order, msize, umsize, merge, unmerge] = ...
        initialize( X, nSource, dimOrder )
% Initialize values for an arrayGrid object

% Ensure the data is numeric or logical
if ~isnumeric(X) && ~islogical(X)
    error('X must be a numeric or logical array.');
end

% Get a placeholder file name and saved variable name
file = 'Saved workspace array';
var = sprintf('source%.f', nSource+1);

% Process dimensions, note merging
[~, msize, order, merge, ~] = gridData.processSourceDims( dimOrder, size(X) );

% Merge data dimensions now.
X = gridData.mergeDims( X, merge );
umsize = msize;
merge = NaN( 1, numel(msize) );
unmerge = NaN( 1, numel(msize) );

end