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

% Check that the dims are all allowed names
gridDims = obj.dims;
if requireDefined
    gridDims = gridDims(obj.isdefined);
end
allowed = ismember(dims, gridDims);

% Build an error message if not.
if any(~allowed)
    bad = find(~allowed,1);
    
    % Single input dim, use the name. Array input, include the list element
    id = sprintf('%s', dims);
    if numel(dims)>1
        id = sprintf('Element %.f in dims (%s)', bad, dims(bad));
    end
    
    % Specify whether dim must be recognized or defined
    require = ["recognized by", "Recognized dimensions"];
    if requireDefined
        require = ["with defined metadata in", "Dimensions with define metadata"];
    end
    
    error('%s is not a dimension %s .grid file %s. %s are %s.', id, require(1), obj.file, require(2), dash.errorStringList(gridDims)); 
end

end