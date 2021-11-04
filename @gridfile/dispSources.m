function[] = dispSources(obj)
%% gridfile.dispSources  Lists gridfile data sources in the console
% ----------
%   obj.dispSources
%   Prints a numbered list of gridfile data sources to the console.
% ----------
% 
% <a href="matlab:dash.doc('gridfile.dispSources')">Documentation Page</a>

nSource = size(obj.dimLimit, 3);
countLength = strlength(string(nSource));
format = sprintf('    %%%.f.f. %%s\n', countLength);

for s = 1:nSource
    fprintf(format, s, obj.sources.source(s));
end
fprintf('\n');

end