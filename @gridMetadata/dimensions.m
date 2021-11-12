function[dimensions, attributes] = dimensions
%% gridMetadata.dimensions  Return the list of gridMetadata dimensions
% ----------
%   dimensions = gridMetadata.dimensions
%   Returns the list of data dimensions recognized by gridMetadata.
%
%   [dimensions, attributes] = gridMetadata.dimensions
%   Also returns the name of the attributes property.
% ----------
%   Outputs:
%       dimensions (string vector): The list of dimensions recognized by
%           gridMetadata
%       attributes (string scalar): The name of the metadata attributes property
%
% <a href="matlab:dash.doc('gridMetadata.dimensions')">Documentation Page</a>

props = properties('gridMetadata');
dimensions = string(props(1:end-2));
if nargout>1
    attributes = string(props(end-1));
end

end