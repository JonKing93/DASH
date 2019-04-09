function[] = checkDim(dim)
%% Checks that dim is a string flag and a member of the recognized dimension IDs.
%
% chekcDim(dim)

% Check that the deletion dimension is allowed
if ~isstrflag(dim)
    error('dim must be a string.')
end

% Check that the dimension is recognized.
dimID = getDimIDs;
if ~ismember(dim, dimID)
    error('The value of dim (%s) is not a recognized dimension ID.', dim);
end

end