function[] = dispSources(obj, objName)
%% gridfile.dispSources  List gridfile data sources in the console
% ----------
%   <strong>obj.dispSources</strong>
%   Prints a numbered list of gridfile data source files to the console.
%   Links to source details using the name of the object in the calling
%   source.
%
%   <strong>obj.dispSources</strong>(objName)
%   Specify the name of the object to use when linking to source details.
% ----------
%   Inputs:
%       objName (string scalar): The name of the object to use when linking
%           to source details.
%
%   Outputs:
%       Prints a list of gridfile data source files to the console.
% 
% <a href="matlab:dash.doc('gridfile.dispSources')">Documentation Page</a>

% Default object name
if ~exist('objName','var') || isempty(objName)
    objName = inputname(1);
end

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
    fprintf([format,'   ',link,'\n'], s, paths(s), objName, s);
end
fprintf('\n');

end