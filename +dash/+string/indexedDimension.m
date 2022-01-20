function[indicesName, dimensionName] = indexedDimension(dimensionName, d, indicesWereCell)

% Get the informative dimension name
if strcmp(dimensionName, "")
    dimensionName = sprintf('indexed dimension %.f', d);
else
    dimensionName = sprintf('the "%s" dimension', dimensionName);
end

% Get the name of the indices
indicesName = sprintf('the indices for %s', dimensionName);

end