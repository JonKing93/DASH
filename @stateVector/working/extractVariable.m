function[Xvar] = extractVariable(X, limits, varLimits)

extractLimits = varLimits - limits(:,1) + 1;
indices = dash.indices.fromLimits(extractLimits);
Xvar = X(indices{:});

end