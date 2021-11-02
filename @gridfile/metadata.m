function[metadata] = metadata(obj, source)
%% gridfile.metadata  Return the metadata for a gridfile
% ----------
%   metadata = obj.metadata
%   Returns the gridMetadata object for a .grid file.
%
%   metadata = obj.metadata(s)
%   metadata = obj.metadata(sourceFilename)
%   Returns the metadata for a data source catalogued in the .grid file.
%   The non-dimensional attributes will match the attributes of the full
%   .grid file.
% ----------
%   Inputs:
%       s (scalar positive integer): The index of a data source in the gridfile
%       sourceFilename (string scalar): The name of a data source in the gridfile
%
%   Outputs:
%       metadata (gridMetadata object): Metadata for the gridfile.
%       
% <a href="matlab:dash.doc('gridfile.metadata')">Documentation Page</a>

% Get up-to-date metadata for the full file
obj.update;
metadata = obj.metadata;

% If no inputs, return metadata directly
if ~exist('source','var')
    return;
end

% Otherwise, error check and parse data source index
s = dash.parse.listOrIndices(source);

% Build the metadata for each dimension of the source
for d = 1:numel(obj.dims)
    dim = obj.dims(d);
    values = metadata.(dim);
    lim = obj.dimLimit(d,:,s);
    
    metadata = metadata.edit(dim, values(lim(1):lim(2),:));
end

end