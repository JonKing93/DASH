function[obj] = updateLengths(obj, vars)

for k = 1:numel(vars)
    v = vars(k);
    sizes = obj.variables_(v).stateSizes;
    obj.lengths(v) = prod(sizes);
end

end