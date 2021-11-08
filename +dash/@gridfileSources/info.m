function[info] = info(obj, s)

% Initialize source structure array
nSource = numel(s);
pre = cell(nSource, 1);
info = struct('name', pre, 'file', pre, 'variable', pre, 'data_type', pre, ...
    'dimensions', pre, 'size', pre, 'data_adjustments', pre, ...
    'uses_relative_path', pre, 'import_options', pre);

% Track optional fields
hasVariables = false;
hasImportOptions = false;
[hasopts, loc] = ismember(s, obj.importOptionSource);

% Build each structure
for k = 1:nSource
    [~, name, ext] = fileparts(obj.source(s(k)));
    name = strcat(name, ext);
    info(k).name = name;
    
    info(k).file = obj.absolutePaths(s(k));
    info(k).uses_relative_path = obj.relativePath(s(k));
    info(k).data_type = obj.dataType(s(k));
    info(k).dimensions = obj.dims(s(k));
    
    if ~strcmp(obj.var(s(k)), "")
        info(k).variable = obj.var(s(k));
        hasVariables = true;
    end
    
    siz = str2double(strsplit(obj.size(s(k)), ','));
    info(k).size = siz;
    
    da = struct('fill_value', obj.fill(s(k)), 'valid_range', obj.range(s(k),:),...
        'transform', obj.transform(s(k)), 'transform_parameters', ...
        obj.transform_params(s(k),:));
    info(k).data_adjustments = da;
    
    if hasopts(k)
        info(k).import_options = obj.importOptions(loc(k));
        hasImportOptions = true;
    end
end

% Remove unnecessary fields
if ~hasVariables
    info = rmfield(info, 'variable');
end
if ~hasImportOptions
    info = rmfield(info, 'import_options');
end

end 