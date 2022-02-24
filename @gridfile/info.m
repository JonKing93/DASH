function[info] = info(obj, sources)
%% gridfile.info  Return information about a gridfile object
% ----------
%   gridInfo = <strong>obj.info</strong>
%   gridInfo = <strong>obj.info</strong>(0)
%   Returns a structure with information about the gridfile. The structure
%   only includes fields pertinent to the entire gridfile. The details of
%   different data sources are not included.
%
%   sourceInfo = <strong>obj.info</strong>(-1)
%   Returns a structure array with information about all the data sources
%   in the gridfile. Each element holds details about one data source in
%   the gridfile. The index of each element in the structure array
%   corresponds the the data source's index in the gridfile.
%
%   sourceInfo = <strong>obj.info</strong>(s)
%   sourceInfo = <strong>obj.info</strong>(sourceNames)
%   Returns a structure array with information about the specified data
%   sources. Each element holds details about one data source. The order of
%   data sources in the info array matches the input order.
% ----------
%   Inputs:
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources about which to return information.
%       sourceNames (string vector): The names of the data sources about
%           which to return information.
%
%   Outputs:
%       gridInfo (scalar struct): A struct with information pertinent to
%           the entire gridfile. Includes the following fields:
%           .file (string scalar): Absolute path to the .grid file
%           .dimensions (string vector [nDims]): The names of the dimensions in the gridfile
%           .dimension_sizes (numeric vector [nDims]): The length of each
%               dimension in the gridfile. Lengths are in the same order as
%               the gridfile dimensions.
%           .metadata (gridMetadata object): Metadata for the gridfile
%           .nSources (numeric scalar): The number of data sources in the gridfile
%           .prefer_relative_paths (scalar logical): True if the gridfile
%               attempts to record the relative paths to data sources by default.
%               False if it always records absolute paths.
%           .fill_value (numeric scalar): The default fill value.
%           .valid_range (numeric vector [2]): The default valid range
%           .transform (string scalar): The default data transformation
%           .transform_parameters (numeric vector [2]): Any parameters
%               needed to implement the default transformation.
%
%       sourceInfo (struct vector): Information about the requested data sources
%           in the gridfile catalogue. A struct vector with one element per
%           requested data source. Each struct has the following fields:
%           .name (string scalar): The name of the data source file
%           .index (numeric scalar): The index of the data source in the gridfile
%           .parent (string scalar): The path to the parent gridfile
%           .file (string scalar): The absolute path to the data source file
%           .file_type (string scalar): The type of source file
%           .path (string scalar): The saved path to the data source file.
%               May differ from the "file" field when using relative paths
%           .uses_relative_path (scalar logical): Whether the saved path is
%               a path relative to the parent gridfile (true) or an
%               absolute path (false).
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
%           .fill_value (numeric scalar): The fill value for the data source
%           .valid_range (numeric vector [2]): The valid range for the data source
%           .transform (string scalar): The data transformation for the data source
%           .transform_parameters (numeric vector [2]): Any parameters needed to 
%               implement the data transformation.
%           .raw_dimensions (string vector): The raw dimensions in the data
%               source file. This is the dimension order before merging.
%           .raw_size (numeric vector): The size of each raw dimension in
%               the data source file.
%
% <a href="matlab:dash.doc('gridfile.info')">Documentation Page</a>

% Setup
header = "DASH:gridfile:info";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

% Parse sources
if ~exist('sources','var') || isequal(sources,0)
    s = 0;
elseif isequal(sources, -1)
    s = 1:obj.nSource;
else
    s = obj.sources_.indices(sources, header);
end

% Information about the entire grid, or for data sources
if isequal(s,0)
    info = gridInfo(obj);
else
    info = obj.sources_.info(s);
end

end

% Utilties
function[info] = gridInfo(obj)

info = struct(...
    'file', obj.file,...
    'dimensions', obj.dims,...
    'dimension_sizes', obj.size,...
    'metadata', obj.meta,...
    'nSources', obj.nSources,...
    'prefer_relative_paths', obj.relativePath,...
    'fill_value', obj.fill,...
    'valid_range', obj.range,...
    'transform', obj.transform_,...
    'transform_parameters', obj.transform_params...
    );

end