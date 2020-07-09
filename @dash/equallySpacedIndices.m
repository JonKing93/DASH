function[indices] = equallySpacedIndices(indices)
if numel(indices)>1
    indices = sort(indices);
    spacing = unique(diff(indices));
    
    if numel(spacing) > 1
        indices = indices(1):indices(end);
    end
end
end