function[] = absolutePaths(obj, useAbsolute, sources)
%% gridfile.absolutePaths  Save data source file names as absolute or relative paths
% ----------
%   <strong>obj.absolutePaths</strong>(useAbsolute)
%   Specify whether the .grid file should save data source locations as
%   relative paths, or absolute paths. This syntax sets the preferred file
%   path style for all data sources currently in the .grid, and applies the
%   style by default to any data sources added to the gridfile in the
%   future.
%
%   By default, a gridfile saves the relative path to data sources whenever
%   possible (useAbsolute = false). Relative data source paths are relative
%   to the folder holding the .grid file. Use this style when 1. moving
%   project folders that hold both .grid files and data sources, or
%   2. uploading a .grid file to a data repository (such as Zenodo).
%
%   If useAbsolute is set to true, the .grid file will instead store the
%   absolute path to data source files. Use this option if you anticipate
%   moving the .grid file, but not the data source files.
%
%   Note: Data source located on a different drive than the .grid file, or
%   accessed via an OPENDAP url, always use an absolute file path. Thus,
%   setting useAbsolute to false does not guarantee that all data sources
%   use relative paths.
%
%   <strong>obj.absolutePaths</strong>(useAbsolute, s)
%   <strong>obj.absolutePaths</strong>(useAbsolute, sources)
%   Implement a preferred path style for the indicated data sources. This
%   syntax overrides any preferred path style previously set for the data
%   sources.
% ----------
%   Inputs:
%       useAbsolute (scalar logical): Set to true to store the absolute
%           path to data source files. Set to false to store relative paths
%           whenever possible. Files located on a different drive, or
%           accessed via an OPENDAP url, will always use an absolute path,
%           regardless of the value of useAbsolute.
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources that should be implement the preferred file
%           path style.
%       sourceName (string vector): The names of the data sources that
%           should implement the preferred file path style.
%
% <a href="matlab:dash.doc('gridfile.absolutePaths')">Documentation Page</a>

% Setup
obj.update;
header = "DASH:gridfile:absolutePaths";

% Error check
dash.assert.scalarType(useAbsolute, 'logical', 'useAbsolute', header);
tryRelative = ~useAbsolute;

% Get data source indices, set gridfile default
if exist('sources','var')
    s = obj.sources_.indices(sources, obj.file, header);
else
    obj.relativePath = tryRelative;
    s = 1:obj.nSource;
end

% Get the absolute paths, use to update each source
absPaths = obj.sources_.absolutePaths(s);
for p = 1:numel(s)
    obj.sources_ = obj.sources_.savePath(absPaths(p), tryRelative, s(p));
end

end