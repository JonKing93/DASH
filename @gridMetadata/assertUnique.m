function[] = assertUnique(obj, header)
%% gridMetadata.assertUnique  Throw error if metadata rows are not unique
% ----------
%   <strong>obj.assertUnique</strong>
%   Checks that the rows of metadata for each dimension are unique. Throws
%   an error if not.
%
%   <strong>obj.assertUnique</strong>(header)
%   Customize the header in thrown error IDs.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('gridMetadata.assertUnique')">Documentation Page</a>

% Default
if ~exist('header','var') || isempty(header)
    header = 'DASH:gridMetadata:assertUnique';
end
obj.assertScalar(header);

% Get the metadata for each defined dimension
dims = obj.defined;
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