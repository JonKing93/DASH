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
%           should be removed. Names may either be just file names, or the
%           full file path / opendap url to the file. 
%
% <a href="matlab:dash.doc('gridfile.remove')">Documentation Page</a>

% Get data source indices
s = gridfile.sourceIndices(sources);

% Remove the sources
obj.source(s) = [];
obj.relativePath(s) = [];
obj.dimLimit(:,:,s) = [];

obj.source_fill(s) = [];
obj.source_range(s,:) = [];
obj.source_transform(s) = [];
obj.source_transform_params(s,:) = [];

% Save
obj.save;

end




