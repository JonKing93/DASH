function[grids, sources, f] = prebuildSources(obj)
%% Pre-builds gridfiles and data sources. Checks that all gridfiles are valid.
%
% [grids, sources, f] = obj.buildGrids
%
% ----- Outputs -----
%
% grids: A cell vector of all unique gridfile objects.
%
% sources: A cell vector the length of grids. Each element of sources is a
%    cell vector with pre-built dataSource objects for the grid.
%
% f: A vector with one element per variable in the state vector. Each
%    element maps a variable to the corresponding unique gridfile.

% Get the .grid files associated with each variable.
files = dash.collectField(obj.variables, 'file');
files = string(files);

% Find the unique gridfiles. Preallocate data sources, grids, and the limits
% of each variable in the state vector
[files, vf, f] = unique(files);
nGrids = numel(files);
grids = cell(nGrids, 1);
sources = cell(nGrids, 1);

% Overview of indices
% v: Index of variable in the state vector
% f: File index associated with variable
% vf: Variable index associated with file

% Check that all gridfiles are valid. Pre-build data sources
for v = 1:numel(obj.variables)
    if ismember(v, vf)
        grids{f(v)} = obj.variables(v).gridfile;
        sources{f(v)} = grids{f(v)}.review;
    end
    obj.variables(v).checkGrid(grids{f(v)});
end

end