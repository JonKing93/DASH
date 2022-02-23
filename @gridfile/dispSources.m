function[] = dispSources(obj)
%% gridfile.dispSources  List gridfile data sources in the console
% ----------
%   <strong>obj.dispSources</strong>
%   Prints a numbered list of gridfile data source files to the console.
% ----------
%   Outputs:
%       Prints a list of gridfile data source files to the console.
% 
% <a href="matlab:dash.doc('gridfile.dispSources')">Documentation Page</a>

% Link to sources. Get filepaths
link = '<a href="matlab:%s.source(%.f)">Show details</a>';
paths = obj.sources_.absolutePaths;

% Format widths
nSource = size(obj.dimLimit, 3);
countLength = strlength(string(nSource));
pathLength = max(strlength(paths));
format = sprintf('        %%%.f.f. %%-%.fs', countLength, pathLength);

% Print each data source path
for s = 1:nSource
    fprintf([format,'   ',link,'\n'], s, paths(s), inputname(1), s);
end
fprintf('\n');

end