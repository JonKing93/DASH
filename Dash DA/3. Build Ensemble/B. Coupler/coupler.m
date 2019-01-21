function[design] = coupler( design, cv )
%
% cv: Variable indices of the coupled variables

% Check that the coupled variables all share the same ensemble dimensions
% and overlap permissions. Return these values.
[ensDim, overlap] = checkOverlap( design.var(cv) );

% Trim the indices in each variable to only allow complete sequences
for k = 1:numel(cv)
    for dim = 1:numel(ensDim)
        design.var(cv(k)) = trimEnsemble( design.var(cv(k)), ensDim{dim} );
    end
end

% Restrict to overlapping metadata
design = restrictMeta( design, cv, ensDim );

% Do the random draws. Get the SAMPLING indices of the ensemble indices.
% (The indices of the ensemble indices, very meta...)
[sampDex, ensID] = drawEnsemble( design.var(cv), nEns, overlap );

% Apply the sampling indices to get the final ensemble indices.
design.var(cv) = assignEnsIndices( design.var(cv), sampDex, ensID);

end