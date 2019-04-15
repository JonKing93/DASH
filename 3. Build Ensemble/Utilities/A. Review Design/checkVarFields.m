function[] = checkVarFields( var )
%% Low level error checking for fields in a varDesign
%
% checkVarFields( var )

% Get the number of dimensions
nDim = numel(var.dimID);

% Get the index / mean / overlap properties
field = properties('varDesign');
field = string( field(6:end-3) );

% Also get the data type of each field
type = ["logical","cell","cell","cell","cell","logical","cell","logical"];

% Check that each field is the correct type, and a vector with an element
% for each dimension.
for f = 1:numel(field)
    if ~isa(var.(field(f)), type(f))
        error('The "%s" field of variable %s is not a %s.', field(f), var.name, type(f) );
    elseif ~isvector(var.(field(f))) || length(var.(field(f)))~=nDim
        error('The "%s" field of variable %s is not a vector with one element for each dimension.', field(f), var.name);
    end
end

% Check that overlap is a scalar logical
if ~islogical(var.overlap) || ~isscalar(var.overlap)
    error('The "overlap" field of variable %s is not a logical scalar.', var.name );
end

end