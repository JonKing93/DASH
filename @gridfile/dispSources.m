function[] = dispSources(obj)
%% gridfile.dispSources  Lists gridfile data sources in the console
% ----------
%   obj.dispSources
%   Prints a numbered list of gridfile data sources to the console.
% ----------
% 
% <a href="matlab:dash.doc('gridfile.dispSources')">Documentation Page</a>

% Format the numbered list
nSource = size(obj.dimLimit, 3);
countLength = strlength(string(nSource));
format = sprintf('    %%%.f.f. %%s\n', countLength);

% Print each data source path
paths = obj.sources_.absolutePaths;
for s = 1:nSource
    fprintf(format, s, paths(s));
end
fprintf('\n');

end