function[] = checkAllowedDims(obj, dims, requireDefined)
%% Checks that input dimensions are allowed for a gridfile operation.
%
% obj.checkAllowedDims(dims, requireDefined)
% Checks that input dimensions are recognized by a .grid file and
% optionally checks that they are also dimensions with defined metadata.
%
% ----- Inputs -----
%
% dims: A list of dimensions input for a gridfile operation. A string
%    vector or cellstring vector.
%
% requireDefined: Scalar logical. Indicates whether the input dimensions
%    must have defined metadata (true) or not (false).

% Default for unset variable.
if ~exist('requireDefined','var') || isempty(requireDefined)
    requireDefined = false;
end
dims = string(dims);

% Get the list of allowed dimensions and its name for error messages.
[~,name,ext] = fileparts(obj.file);
filename = strcat(name, ext);
if requireDefined
    allowed = obj.dims(obj.isDefined);
    allowedName = sprintf('dimension with defined metadata in .grid file %s', filename);
else
    allowed = obj.dims;
    allowedName = sprintf('dimension recognized by .grid file %s', filename);
end

% Check the dimensions are allowed
dash.checkStrsInList(dims, allowed, 'dims', allowedName);

end