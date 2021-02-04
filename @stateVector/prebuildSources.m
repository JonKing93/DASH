function[grids] = prebuildSources(obj)
%% Pre-builds gridfiles and data sources. Checks that all gridfiles are valid.
%
% [grids] = obj.prebuildSources
%
% ----- Outputs -----
%
% grids: A prebuiltGrids object

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

% Combine into a prebuiltGrids
grids = prebuiltGrids(grids, sources, f);

end