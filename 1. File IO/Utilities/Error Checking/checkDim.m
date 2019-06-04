function[] = checkDim(dim, useSpec)
%% Checks that dim is a string flag and a member of the recognized dimension IDs.
%
% chekcDim(dim)
% checkDim(dim, false)
% Checks if a dimension is in the set of dimension IDs
%
% checkDim(dim, true)
% Checks if a dimension is in the set of dimension IDs or the specs field

% Get the flag
if nargin == 1
    useSpec = false;
elseif ~islogical(useSpec) || ~isscalar(useSpec)
    error('useSpec must be a scalar logical.');
end

% Check that the deletion dimension is allowed
if ~isstrflag(dim)
    error('dim must be a string.')
end

% Get the allowed dimensions
[dimID, specs] = getDimIDs;
if useSpec
    dimID = [dimID, specs];
end

% Check that dim is recognized
if ~ismember(dim, dimID)
    error('%s is not a recognized dimension ID.', dim);
end

end