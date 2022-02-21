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

% Require scalar
dash.assert.scalarObj(obj, 'DASH:gridfile:dispSources');

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