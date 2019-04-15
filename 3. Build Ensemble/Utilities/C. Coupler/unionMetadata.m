function[U, iA] = unionMetadata( A, B )
%% Gets the union of n-dimensional metadata by row

% Initialize the union
iA = [];

% For each row of each dataset
for k = 1:size(A,1)
    for j = 1:size(B,1)
        
        % Test for equality
        isU = isequaln( A(k,:), B(j,:) );
        
        % If equal, add to the union
        if isU
            iA = [iA; k]; %#ok<AGROW>
        end
    end
end

% Get the metadata union, preserving inherent dimensionality
U = indexMetadata( A, iA );

end
   