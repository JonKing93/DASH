function[info] = info(obj, sources)

% gridInfo = obj.info
% gridInfo = obj.info(0)
% Returns a structure with information about the gridfile.
%
% sourceInfo = obj.info([])
% sourceInfo = obj.info(-1)
% Returns a structure array with information about all the data sources in
% the gridfile.
%
% sourceInfo = obj.info(s)
% sourceInfo = obj.info(sourceNames)
% Returns a structure array with information about the specified data
% sources.

% Setup
obj.update;
header = "DASH:gridfile:info";

% Default sources
if ~exist('sources','var')
    sources = 0;
end

% Grid info
if isnumeric(sources) && sources==0
    da = struct('fill_value', obj.fill, 'valid_range', obj.range, 'transform', ...
        obj.transform_, 'transform_parameters', obj.transform_params);
    info = struct('file', obj.file, 'dimensions', obj.dims, ...
        'dimension_sizes', obj.size, 'metadata', obj.meta, ...
        'data_adjustments', da, 'nSources', obj.nSource, ...
        'prefer_relative_paths', obj.relativePath);
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