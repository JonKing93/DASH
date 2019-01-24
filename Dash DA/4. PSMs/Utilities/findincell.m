function[index] = findincell( a, C )
%% Finds the location of an element in a cell vector.
%
% index = findincell( a, C )
% Finds the locations of a in cell vector C.

% If a is a scalar cell, get the inner element
if isscalar(a) && iscell(a)
    a = a{:};
end

% Preallocate the indices
index = false(numel(C),1);

% For each cell element
for c = 1:numel(C)

    % Check for comparison
    if isequaln( C{c}, a )

        % Record match
        index(c) = true;
    end
end

% Return the indices
index = find(index);

end