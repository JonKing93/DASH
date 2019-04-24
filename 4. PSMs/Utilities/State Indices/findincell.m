function[index] = findincell( a, C )
%% Finds the location of an element in a cell vector.
%
% index = findincell( a, C )
% Finds the locations of a in cell vector C. If a is a cell scalar, finds
% the location of a{1} inside C.
%
% ----- Inputs -----
%
% a: A value or cell scalar containing a value
%
% C: A cell vector
%
% ----- Outputs -----
%
% index: The indices of a in C.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

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