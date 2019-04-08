function[gridDims] = checkDims(gridDims)
%% Check that user-specified dimensions are recognized and non-duplicate
%
% checkDims(gridDims)

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

end