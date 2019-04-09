function[gridDims] = checkGridDims(gridDims, gridData)
%% Check that gridded dimensions are recognized and non-duplicate
%
% checkDims(gridDims, gridData)

% Check for duplicates
if numel(gridDims) ~= numel(unique(gridDims))
    error('gridDims cannot contain repeat dimensions.');
end

% Check that gridDims is a set of character vectors or strings
for d = 1:numel(gridDims)
    if ( iscell(gridDims(d)) && ~isstrflag(gridDims{d}) ) || (~iscell(gridDims(d)) && ~isstrflag(gridDims(d)))
        error('gridDims must either be a set of character row vectors, or a set of strings.');
    end
end

% Convert cellstr to string
gridDims = string(gridDims);

% Load the recognized IDs
[dimID] = getDimIDs;

% Check that each dim is recognized
isdim = ismember(gridDims, dimID);
if any( ~isdim )
    d = find( ~isdim, 1, 'first' );
    error('Grid dimension %0.f ("%s") is not a recognized dimension ID.',d, gridDims(d));
end

% If gridded data is provided
if exist( 'gridData', 'var' )
    
    % Get the number of dimensions in the gridded data
    if iscolumn(gridData)
        nDim = 1;
    else
        nDim = ndims(gridData);
    end

    % Ensure there is a gridDim for each dimension that is not a trailing singleton
    if numel(gridDims) < nDim
        error('gridDims only contains %.f dimension IDs, but the gridded data has at least %.f dimensions.', numel(gridDims), nDim);
    end
end

end