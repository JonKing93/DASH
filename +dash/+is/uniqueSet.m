function[tf, repeat] = uniqueSet(X, rows)
%% dash.is.uniqueSet  Test if input has repeated elements
% ----------
%   tf = dash.is.uniqueSet(X)
%   Returns true if a vector contains repeated values. Otherwise, returns
%   false.
%
%   tf = dash.is.uniqueSet(X, true)
%   Returns true if a matrix contains repeated rows. Otherwise, returns
%   false.
%
%   [tf, repeat] = dash.is.uniqueSet(...)
%   Also returns the indices to the first set of repeated values.
% ----------
%   Inputs:
%       X (vector | matrix): The input being tested
%       
%   Outputs:
%       tf (scalar logical): True if X has repeated values. Otherwise, false
%       repeat (vector, linear indices): The indices of the first set of
%           repeated values.
%
% <a href="matlab:dash.doc('dash.is.uniqueSet')">Documentation Page</a>

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
if numel(uniqElements) == nEls
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