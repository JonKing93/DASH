function[dims, atts] = dimensions
%% gridMetadata.dimensions  Return the list of gridMetadata dimensions
% ----------
%   dims = gridMetadata.dimensions
%   Returns the list of data dimensions recognized by gridMetadata.
%
%   [dims, atts] = gridMetadata.dimensions
%   Also returns the name of the attributes property.
% ----------
%   Outputs:
%       dims (string vector): The list of dimensions recognized by
%           gridMetadata
%       atts (string scalar): The name of the metadata attributes property
%
% <a href="matlab:dash.doc('gridMetadata.dimensions')">Documentation Page</a>

props = properties('gridMetadata');
dims = string(props(1:end-1));
if nargout>1
    atts = string(props(end));
end

end