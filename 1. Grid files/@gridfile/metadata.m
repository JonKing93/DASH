function[meta] = metadata(file, includeUndefined)
%% Returns the metadata for a .grid file.
%
% meta = gridfile.metadata(file)
% Returns the metadata for the specified file.
%
% meta = gridfile.metadata(file, includeUndefined)
% Optionally include metadata for internal .grid dimensions with undefined
% metadata. Default is to only return defined metadata.
%
% *** Note: If you would like to access the metadata in a gridfile object,
% use:  >> obj.meta
%
% ----- Inputs -----
%
% file: The name of the .grid file.
%
% includeUndefined: A scalar logical indicating whether to include metadata
%    for internal .grid dimensions with undefined metadata. Default is
%    false.
%
% grid: An instance of a gridfile object.
%
% ----- Outputs -----
%
% meta: The metadata structure for the .grid file.

% Defaults for unset variables
if ~exist('includeUndefined','var') || isempty(includeUndefined)
    includeUndefined = false;
end

% Error check
if ~isscalar(includeUndefined) || ~islogical(includeUndefined)
    error('includeUndefined must be a scalar logical.');
end

% Get a gridfile object (this will error check the file). Extract the metadata
grid = gridfile(file);
meta = grid.meta;

% Optionally remove undefined dimensions
if ~includeUndefined
    undefined = grid.dims( ~grid.isdefined );
    meta = rmfield(meta, undefined);
end

end