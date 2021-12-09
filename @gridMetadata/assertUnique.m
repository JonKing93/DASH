function[] = assertUnique(obj, dimensions, header)
%% gridMetadata.assertUnique  Throw error if metadata rows are not unique
% ----------
%   <strong>obj.assertUnique</strong>
%   <strong>obj.assertUnique</strong>([])
%   Checks that the rows of metadata for each dimension are unique. Throws
%   an error if not.
%
%   <strong>obj.assertUnique</strong>(dimensions)
%   Checks that the rows of metadata for the specified dimensions are
%   unique. Throws an error if not.
%
%   <strong>obj.assertUnique</strong>(..., header)
%   Customize the header in thrown error IDs.
% ----------
%   Inputs:
%       dimensions (string list | empty array): The names of dimensions
%           that should be checked for unique metadata rows. Can only
%           include dimensions defined in the metadata. If an empty array,
%           checks the metadata for all dimensions.
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('gridMetadata.assertUnique')">Documentation Page</a>

% Default header, require scalar object
if ~exist('header','var') || isempty(header)
    header = 'DASH:gridMetadata:assertUnique';
end
obj.assertScalar(header);

% Dimensions
defined = obj.defined;
if ~exist('dimensions','var') || isempty(dimensions)
    dims = obj.defined;
else
    dims = dash.assert.strlist(dimensions, 'dimensions', header);
    dash.assert.strsInList(dims, defined, 'dimensions', 'dimension defined in the metadata', header);
end

% Get the metadata for each defined dimension
for d = 1:numel(dims)
    dim = dims(d);
    meta = obj.(dim);
    
    % Throw error if rows are not unique
    [areUnique, repeats] = dash.is.uniqueSet(meta, true);
    if ~areUnique
        id = sprintf('%s:duplicateRows', header);
        error(id, 'The "%s" metadata has duplicate rows. (Rows %s)',...
            dim, dash.string.list(repeats));
    end
end

end