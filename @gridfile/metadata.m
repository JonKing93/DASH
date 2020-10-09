function[meta] = metadata(obj, includeUndefined)
%% Returns the metadata for a .grid file.
%
% meta = obj.metadata
% Returns the metadata for a .grid file.
%
% meta = obj.metadata(includeUndefined)
% Optionally include metadata for internal .grid dimensions with undefined
% metadata. Default is to only return defined metadata.
%
% ----- Inputs -----
%
% includeUndefined: A scalar logical indicating whether to include metadata
%    for internal .grid dimensions with undefined metadata. Default is
%    false.
%
% ----- Outputs -----
%
% meta: The metadata structure for the .grid file.

% Defaults  and error check for includeUndefined
if ~exist('includeUndefined','var') || isempty(includeUndefined)
    includeUndefined = false;
end
dash.assertScalarType(includeUndefined, 'includeUndefined', 'logical', 'logical');

% Extract the metadata
obj.update;
meta = obj.meta;

% Optionally remove undefined dimensions
if ~includeUndefined
    undefined = obj.dims( ~obj.isdefined );
    meta = rmfield(meta, undefined);
end

end