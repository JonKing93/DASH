function[] = remove(obj, sources)
%% gridfile.remove  Remove data sources from a .grid file's catalogue
% ----------
%   obj.remove(s)
%   obj.remove(sourceName)
%   Removes the specified data sources from the gridfile.
% ----------
%   Inputs:
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources that should be removed.
%       sourceName (string vector): The names of the data sources that
%           should be removed. Names may be absolute file paths, the names
%           of files on the active path, or opendap urls.
%
% <a href="matlab:dash.doc('gridfile.remove')">Documentation Page</a>

% Get data source indices
header = "DASH:gridfile:remove";
s = obj.sources.indices(sources, obj.file, header);

% Remove the sources
obj.dimLimit(:,:,s) = [];
obj.sources = obj.sources.remove(s);
obj.nSource = size(obj.dimLimit, 3);

% Save
obj.save;

end




