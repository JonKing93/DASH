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

% Link to sources
link = '<a href="matlab:%s.source(%.f)">Show details</a>';

% Format the numbered list
nSource = size(obj.dimLimit, 3);
countLength = strlength(string(nSource));
format = sprintf('        %%%.f.f. %%s', countLength);

% Print each data source path
paths = obj.sources_.absolutePaths;
for s = 1:nSource
    fprintf([format,'   ',link,'\n'], s, paths(s), inputname(1), s);
end
fprintf('\n');

end