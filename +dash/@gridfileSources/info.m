function[info] = info(obj, s)
%% dash.gridfileSources.info  Return information about data sources in the catalogue
% ----------
%   info = obj.info(s)
%   Returns a struct array with information about the specified data
%   sources.
% ----------
%   Inputs:
%       s (vector, linear indices): The indices of the data sources for
%           which to return information.
%   
%   Outputs:
%       info (struct vector): Information about the requested data sources
%           in the catalogue. Includes the following fields:
%           .name (string scalar): The name of the data source file
%           .variable (string scalar): The name of the saved variable in a
%               NetCDF or MAT-file. Empty for delimited text data sources.
%           .index (numeric scalar): The index of the data source in the gridfile
%           .file (string scalar): The absolute path to the data source file
%           .data_type (string scalar): The data type of the data saved in
%               the source file.
%           .dimensions (string vector): The names of the dimensions for the
%               data in the source file.
%           .size (numeric vector): The size of each dimension for the data
%               in the source file.
%           .data_adjustments (scalar struct): Has the following fields:
%               .fill_value (numeric scalar): The fill value for the data source
%               .valid_range (numeric vector [2]): The valid range for the data source
%               .transform (string scalar): The data transformation for the data source
%               .transform_parameters (numeric vector [2]): Any parameters needed to 
%                   implement the data transformation.
%           .uses_relative_path (scalar logical): True if the gridfile
%               records the relative path to the data source. False if the
%               gridfile records the absolute path.
%           .import_options (cell scalar): Any import options provided for
%               delimited text data sources. Empty for NetCDF and MAT-file sources
%
% <a href="matlab:dash.doc('dash.gridfileSources.info')">Documentation Page</a>

% Initialize source structure array
nSource = numel(s);
pre = cell(nSource, 1);
info = struct('name', pre, 'variable', pre, 'index', pre, 'file', pre, 'data_type', pre, ...
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
    
    info(k).index = s(k);
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