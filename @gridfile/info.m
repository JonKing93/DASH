function[info] = info(obj, sources)
%% gridfile.info  Return information about a gridfile object
% ----------
%   gridInfo = <strong>obj.info</strong>
%   gridInfo = <strong>obj.info</strong>(0)
%   Returns a structure with information about the gridfile. The structure
%   only includes fields pertinent to the entire gridfile. The details of
%   different data sources are not included.
%
%   sourceInfo = <strong>obj.info</strong>([])
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
%       sourceInfo (struct vector): Information about the individual data
%           sources in the gridfile. Includes the following fields:
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
%           .uses_relative_path (scalar logical): True if the gridfile
%               records the relative path to the data source. False if the
%               gridfile records the absolute path.
%           .import_options (cell scalar): Any import options provided for
%               delimited text data sources. Empty for NetCDF and MAT-file sources
%           .fill_value (numeric scalar): The fill value for the data source
%           .valid_range (numeric vector [2]): The valid range for the data source
%           .transform (string scalar): The data transformation for the data source
%           .transform_parameters (numeric vector [2]): Any parameters needed to 
%               implement the data transformation.
%
% <a href="matlab:dash.doc('gridfile.info')">Documentation Page</a>

% Setup
header = "DASH:gridfile:info";
dash.assert.scalarObj(obj, header);
obj.update;

% Default sources
if ~exist('sources','var')
    sources = 0;
end

% Grid info
if isnumeric(sources) && sources==0
    info = struct('file', obj.file, 'dimensions', obj.dims, ...
        'dimension_sizes', obj.size, 'metadata', obj.meta, ...
        'nSources', obj.nSource, 'prefer_relative_paths', obj.relativePath,...
        'fill_value', obj.fill, 'valid_range', obj.range, 'transform', ...
        obj.transform_, 'transform_parameters', obj.transform_params);
    return;
end

% Otherwise, parse source indices
if isempty(sources) || (isnumeric(sources) && sources==-1)
    s = 1:obj.nSource;
else
    s = obj.sources_.indices(sources, header);
end

% Get the source information
info = obj.sources_.info(s);

end