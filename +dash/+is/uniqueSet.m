function[tf, repeat] = uniqueSet(X, rows)

% Default
if ~exist('rows','var') || isempty(rows)
    rows = false;
end

% Get the rows option
if rows
    rowsOption = {'rows'};
    nEls = size(X,1);
else
    rowsOption = {};
    nEls = numel(X);
end

% Get the locations of unique values
[~, uniqElements, locInX] = unique(X, rowsOption{:});

% If the set is unique, it passes and there are no repeats
if numel(uniqueElements) == nEls
    tf = true;
    repeat = [];
    
% Otherwise, the test fails. Return indices of first set of repeats
else
    tf = false;
    allElements = 1:nEls;
    repeat = find(~ismember(allElements, uniqElements), 1);
    repeat = find(locInX==locInX(repeat));
end

end