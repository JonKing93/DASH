function[metadata] = metadata(obj, sources)
%% gridfile.metadata  Return the metadata for a gridfile
% ----------
%   metadata = <strong>obj.metadata</strong>
%   metadata = <strong>obj.metadata</strong>(0)
%   Returns the gridMetadata object for a .grid file.
%
%   sourceMetadata = <strong>obj.metadata</strong>(-1)
%   sourceMetadata = <strong>obj.metadata</strong>(s)
%   sourceMetadata = <strong>obj.metadata</strong>(sourceNames)
%   Returns the metadata for the specified data sources. If -1 is provided
%   as input, returns the metadata for all data sources in the gridfile.
% ----------
%   Inputs:
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources for which to return metadata.
%       sourceName (string vector): The names of the data sources for which
%           to return metadata.
%
%   Outputs:
%       metadata (scalar gridMetadata object): Metadata for the gridfile.
%       sourceMetadata (gridMetadata vector [nSource]): Metadata for each
%           specified data source.
%       
% <a href="matlab:dash.doc('gridfile.metadata')">Documentation Page</a>

% Setup
header = "DASH:gridfile:metadata";
dash.assert.scalarObj(obj, header);
obj.assertValid;
obj.update;

% If no inputs, return metadata directly
metadata = obj.meta;
if ~exist('sources','var') || isequal(sources, 0)
    return;
end

% Otherwise, get data source indices
if isequal(sources, -1)
    sources = 1:obj.nSource;
else
    sources = obj.sources_.indices(sources, header);
end

% Preallocate source metadata
nSource = numel(sources);
sourceMetadata = repmat(gridMetadata, [nSource, 1]);

% Get metadata for each dimension of each source
for d = 1:numel(obj.dims)
    dim = obj.dims(d);
    values = metadata.(dim);
    
    for k = 1:nSource
        s = sources(k);
        rows = obj.dimLimit(d,1,s):obj.dimLimit(d,2,s);
        sourceMetadata(k) = sourceMetadata(k).edit(dim, values(rows,:));
    end
end
metadata = sourceMetadata;

end