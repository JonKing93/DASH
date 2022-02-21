function[info] = info(obj, s)
%% dash.gridfileSources.info  Return information about data sources in the catalogue
% ----------
%   info = <strong>obj.info</strong>(s)
%   Returns a struct array with information about the specified data
%   sources.
% ----------
%   Inputs:
%       s (vector, linear indices): The indices of the data sources for
%           which to return information.
%   
%   Outputs:
%       info (struct vector): Information about the requested data sources
%           in the gridfile catalogue. A struct vector with one element per
%           requested data source. Each struct has the following fields:
%
%           .name (string scalar): The name of the data source file
%           .index (numeric scalar): The index of the data source in the gridfile
%           .parent (string scalar): The path to the parent gridfile
%           
%           .file (string scalar): The absolute path to the data source file
%           .file_type (string scalar): The type of source file
%           .path (string scalar): The saved path to the data source file.
%               May differ from the "file" field when using relative paths
%           .uses_relative_path (scalar logical): Whether the saved path is
%               a path relative to the parent gridfile (true) or an
%               absolute path (false).
%           
%           .variable (string scalar): The name of the catalogued variable
%               for a NetCDF for MAT-file. Empty for delimited text data sources.
%           .import_options (cell scalar): Import options used to read data
%               from delimited text files. Empty for NetCDF and MAT-file
%               data sources.
%           .data_type (string scalar): The data type of the values saved
%               in the source file.
%           .dimensions (string vector): The gridfile dimensions of the data
%               in the source file. (Note: This is the order of dimensions
%               after merging).
%           .size (numeric vector): The size of each (gridfile) dimension
%               for the data in the source file.
%
%           .fill_value (numeric scalar): The fill value for the data source
%           .valid_range (numeric vector [2]): The valid range for the data source
%           .transform (string scalar): The data transformation for the data source
%           .transform_parameters (numeric vector [2]): Any parameters needed to 
%               implement the data transformation.
%
%           .raw_dimensions (string vector): The raw dimensions in the data
%               source file. This is the dimension order before merging.
%           .raw_size (numeric vector): The size of each raw dimension in
%               the data source file.
%
% <a href="matlab:dash.doc('dash.gridfileSources.info')">Documentation Page</a>

% Initialize source structure array
nSource = numel(s);
pre = cell(nSource, 1);
info = struct('parent',pre, 'source_index', pre, 'name', pre, ...
    'file',pre,'file_type',pre,'path',pre,'uses_relative_path',pre,...
    'variable',pre,'import_options',pre,'data_type',pre,'dimensions',pre,'size',pre,...
    'fill_value',pre,'valid_range',pre,'transform',pre,'transform_parameters',pre,...
    'raw_dimensions',pre,'raw_size',pre);

% Get the paths
paths = obj.absolutePaths(s);

% Build each structure
for k = 1:nSource
    [~,name,ext] = fileparts(paths(k));
    name = strcat(name, ext);
    info(k).name = name;
    info(k).parent = obj.gridfile;
    info(k).index = s(k);

    % File and path
    info(k).file = paths(k);
    type = obj.type(s(k));
    if strcmp(type, 'mat')
        type = 'MAT-file';
    elseif strcmp(type, 'nc')
        type = 'NetCDF';
    elseif strcmp(type, 'text')
        type = 'Delimited text';
    end
    info(k).type = type;
    info(k).path = obj.source(s(k));
    info(k).uses_relative_path = obj.relativePath(s(k));

    % Unpack dimensions
    [rawDims, rawSizes, mergeDims, mergeSizes] = obj.unpack(s(k));

    % Variable, type, import, dimensions
    info(k).variable = obj.var(s(k));
    [hasopts, loc] = ismember(s(k), obj.importOptionSource);
    if hasopts
        info(k).importOptions = obj.importOptions{loc};
    end
    info(k).data_type = obj.dataType(s(k));
    info(k).dimensions = mergeDims;
    info(k).size = mergeSizes;

    % Data adjustments
    info(k).fill_value = obj.fill(s(k));
    info(k).valid_range = obj.range(s(k),:);
    info(k).transform = obj.transform(s(k));
    info(k).transform_parameters = obj.transform_params(s(k),:);

    % Raw sizes
    info(k).raw_dimensions = rawDims;
    info(k).raw_sizes = rawSizes;
end

end