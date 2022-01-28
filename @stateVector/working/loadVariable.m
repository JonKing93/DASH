function[Xvar] = loadVariable(grid, s, sources, limits, precision)
%% Loads all members of a variable at once
%
% grid: The gridfile
% s: The indices of the required sources
% sources: The built sources

indices = dash.indices.fromLimits(limits);
Xvar = grid.loadInternal([], indices, s, sources, precision);

end