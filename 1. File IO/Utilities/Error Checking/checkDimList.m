function[dims] = checkDimList( dims, errName )
%% Checks that a list of dimensions is allowed and recognized. Returns them
% as a string.
%
% errName: The name of the list of dimensions used in error messages.

% Check that the format is correct
if ~isstrlist( dims )
    error('%s must be a cell vector of character row vectors (cellstring) or a string vector.', errName);
end

% Convert to string
dims = string(dims);

% Get the allowed dimension names
dimID = getDimIDs;

% Check that all the dimensions are recognized.
isdim = ismember(dims, dimID);
if any( ~isdim )
    d = find( ~isdim, 1, 'first' );
    error('%s is not a recognized dimension ID.', dim(d) );
end

end