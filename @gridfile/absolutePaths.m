function[] = absolutePaths(obj, useAbsolute, sources)
%% gridfile.absolutePaths  Save data source file names as absolute or relative paths
% ----------
%   <strong>obj.absolutePaths</strong>(setting)
%   <strong>obj.absolutePaths</strong>(true|"u"|"use")
%   <strong>obj.absolutePaths</strong>(false|"a"|"avoid")
%   Specify whether the .grid file should save data source file locations
%   as absolute paths, or avoid absolute paths (and use relative paths)
%   whenever possible. This syntax sets the preferred file path style for
%   all data sources currently in the .grid file and applies the style by
%   default to any new data sources added to the gridfile in the future.
%
%   By default, a gridfile saves the relative path to data sources whenever
%   possible. Relative data source paths are stored relative
%   to the folder holding the .grid file. Use this style when:
%   1. Moving project folders that hold both .grid files and data sources, or
%   2. Uploading a .grid file to a data repository (such as Github, Zenodo, or figshare).
%
%   If the setting="use", the .grid file will instead store the
%   absolute path to data source files. Use this option if you anticipate
%   moving the .grid file, but not the data source files.
%
%   Note: Not all data source locations can be stored as relative paths.
%   Data sources located on a different drive than the .grid file, or
%   accessed via an OPENDAP url, will always use an absolute file path. Thus,
%   setting useAbsolute to "avoid" does not guarantee that a data source
%   file location uses a relative path.
%
%   <strong>obj.absolutePaths</strong>(setting, 0)
%   <strong>obj.absolutePaths</strong>(setting, s)
%   <strong>obj.absolutePaths</strong>(setting, sourceNames)
%   Implement a preferred path style for the indicated data sources. This
%   syntax overrides any preferred path style previously set for the data
%   sources. If the second input is 0, applies the setting to all data
%   sources currently in the .grid file.
% ----------
%   Inputs:
%       setting (scalar logical): Indicates the preferred use of absolute
%           file paths for saved data source file locations:
%           [true|"u"|"use"]: Always save the absolute paths to sources
%           [false|"a"|"avoid"]: Only use absolute paths when necessary
%
%           Regardless of setting, files that are
%           1. Located oOn a different drive, or
%           2. Accessed via an OPENDAP url
%           will always use an absolute path.
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources that should be implement the preferred file
%           path style.
%       sourceNames (string vector): The names of the data sources that
%           should implement the preferred file path style.
%
% <a href="matlab:dash.doc('gridfile.absolutePaths')">Documentation Page</a>

% Setup
header = "DASH:gridfile:absolutePaths";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

% Error check
dash.assert.scalarType(useAbsolute, 'logical', 'useAbsolute', header);
tryRelative = ~useAbsolute;

% Get data source indices, set gridfile default
if ~exist('sources','var') || isequal(sources, 0)
    obj.relativePath = tryRelative;
    s = 1:obj.nSource;
else
    s = obj.sources_.indices(sources, header);
end

% Get the absolute paths, use to update each source
absPaths = obj.sources_.absolutePaths(s);
for p = 1:numel(s)
    obj.sources_ = obj.sources_.savePath(absPaths(p), tryRelative, s(p));
end

% Save
obj.save;

end