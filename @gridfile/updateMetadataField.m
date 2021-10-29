function[] = updateMetadataField( obj, dim, meta )
%% gridfile.updateMetadataFile  Updates the a metadata for a dimension in a .grid file
% ----------
%   <strong>obj.updateMetadataField</strong>(dim, meta);
%   Updates the dimension specified by dim with the new metadata specified by
%   meta
% ----------
%   Inputs:
%       dim (string scalar): The name of the dimension to update
%       meta (matrix - numeric | logical | char | string | datetime): The
%           new metadata for the dimension. Must have the same number of
%           rows as the previous metadata
%
% <a href="matlab:dash.doc('gridfile.updateMetadataField')">Documentation Page</a>

d = strcmp(dim, obj.dims);
obj.meta.(dim) = meta;
obj.size(d) = size(meta, 1);
obj.isdefined(d) = true;
obj.save;

end