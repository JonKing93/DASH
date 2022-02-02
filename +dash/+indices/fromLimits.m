function[indices] = fromLimits(limits)

% Preallocate
nDims = size(limits,1);
indices = cell(nDims, 1);

% Get indices for each dimension
for d = 1:nDims
    indices{d} = limits(d,1):limits(d,2);
end

end