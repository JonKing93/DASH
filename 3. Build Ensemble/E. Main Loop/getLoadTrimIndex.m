function[load, trim] = getLoadTrimIndex( var, d )
%% Gets the initial load and trim index indices for a dimension in a variable.
%
% var: varDesing
%
% d: Dimension index
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% For state dimensions, loading batches of state indices
if var.isState(d)
    index = var.indices{d};
    
% For ensemble dimensions, loading batches of mean indices
else
    index = var.meanDex{d};
end

% Sort the indices
index = sort(index);

% If the indices use a uniform spacing
if numel(unique(diff(index)))==1 || numel(index)==1
    
    % Directly load the dimension
    load = index;
    trim = ':';
    
% Otherwise, unequal spacing
else
    
    % Load everything on the interval and trim later
    load = min(index):max(index);
    [~, trim] = ismember(index, load);
end

end