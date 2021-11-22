function[obj] = remove(obj, s)
%% dash.gridfileSources.remove  Remove data sources from the catalogue
% ----------
%   obj = <strong>obj.remove</strong>(s)
%   Removes the indicated sources from the catalogue.
% ----------
%   Inputs:
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources to remove from the catalogue.
%
%   Outputs:
%       obj (scalar gridfileSources object): The updated catalogue.
%
% <a href="matlab:dash.doc('dash.gridfileSources.remove')">Documentation Page</a>

% Remove indexed import options
remove = find(ismember(obj.importOptionSource, s));
obj.importOptions(remove) = [];
obj.importOptionSource(remove) = [];

% Update import option source indices
for k = 1:numel(obj.importOptionSource)
    index = obj.importOptionSource(k);
    lower = sum(s<index);
    obj.importOptionSource(k) = index - lower;
end

% Remove everything else
obj.type(s) = [];
obj.source(s) = [];
obj.relativePath(s) = [];
obj.dataType(s) = [];
obj.var(s) = [];
obj.dims(s) = [];
obj.size(s) = [];
obj.mergedDims(s) = [];
obj.mergedSize(s) = [];
obj.mergeMap(s) = [];
obj.fill(s) = [];
obj.range(s,:) = [];
obj.transform(s) = [];
obj.transform_params(s,:) = [];

end