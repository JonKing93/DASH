function[d] = dimensionIndices(obj, dimensions)

[~, d] = ismember(dimensions, obj.dims);

end