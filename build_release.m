function mltbxFile = build_release(newVersion, varargin)
%% build_release  Bump the DASH version, run tests, and package a .mltbx
% ----------
%   mltbxFile = build_release(newVersion)
%   Prepares a DASH release. Writes the version string into BOTH
%   +dash/version.m and DASH.prj, runs the toolbox unit tests
%   (dash.testToolbox) as a safety gate, and packages a versioned toolbox
%   file, DASH-<version>.mltbx, in the repository root. Returns the full
%   path to the packaged .mltbx file.
%
%   mltbxFile = build_release(newVersion, 'SkipTests', true)
%   Skips the dash.testToolbox gate. Default is false, i.e. the tests are
%   run and the build aborts (throws) if any test fails.
%
%   mltbxFile = build_release(newVersion, 'OutputDir', folder)
%   Writes the .mltbx to the specified folder instead of the repo root.
% ----------
%   Inputs:
%       newVersion (string scalar | char vector): The new version, with or
%           without a leading 'v', e.g. "v4.2.4" or "4.2.4". Must be of the
%           form MAJOR.MINOR.PATCH.
%       'SkipTests' (scalar logical): Skip the test gate [default false].
%       'OutputDir' (string scalar | char vector): Where to write the
%           .mltbx [default: the repository root].
%
%   Outputs:
%       mltbxFile (char vector): Full path to DASH-<version>.mltbx.
%
%   Example:
%       build_release('v4.2.4')

% Parse inputs. (inputParser is MATLAB's standard name-value parser; the
% equivalent of hand-rolling varargin checks you'd do in older code.)
p = inputParser;
p.addRequired( 'newVersion',            @(x) ischar(x) || isStringScalar(x));
p.addParameter('SkipTests', false,      @(x) islogical(x) && isscalar(x));
p.addParameter('OutputDir', '',         @(x) ischar(x) || isStringScalar(x));
p.parse(newVersion, varargin{:});
skipTests = p.Results.SkipTests;
outputDir = char(p.Results.OutputDir);

% The repo root is simply the folder this script lives in.
repo = fileparts(mfilename('fullpath'));
if isempty(outputDir)
    outputDir = repo;
end

% Normalise and validate the version. Strip any leading 'v', then require
% exactly MAJOR.MINOR.PATCH so a typo can't silently produce a bad release.
vstr = regexprep(char(newVersion), '^[vV]', '');
assert(~isempty(regexp(vstr, '^\d+\.\d+\.\d+$', 'once')), ...
    'build_release:badVersion', ...
    'Version must be MAJOR.MINOR.PATCH (e.g. "4.2.4"), got "%s".', char(newVersion));
vTag  = ['v' vstr];   % form stored in version.m, e.g. v4.2.4
vBare = vstr;         % form stored in DASH.prj,  e.g. 4.2.4

fprintf('\n=== Building DASH release %s ===\n', vTag);

% --- 1. Update +dash/version.m -------------------------------------------
verFile = fullfile(repo, '+dash', 'version.m');
txt     = fileread(verFile);
newtxt  = regexprep(txt, 'version\s*=\s*"v?\d+\.\d+\.\d+"', ...
                    ['version = "' vTag '"']);
assert(contains(newtxt, ['version = "' vTag '"']), ...
    'build_release:versionNotUpdated', ...
    'Could not find the version string to replace in %s.', verFile);
localWrite(verFile, newtxt);
fprintf('  version.m -> %s\n', vTag);

% --- 2. Update DASH.prj <param.version> ----------------------------------
prjFile = fullfile(repo, 'DASH.prj');
ptxt    = fileread(prjFile);
newptxt = regexprep(ptxt, '<param\.version>.*?</param\.version>', ...
                    ['<param.version>' vBare '</param.version>']);
assert(contains(newptxt, ['<param.version>' vBare '</param.version>']), ...
    'build_release:prjNotUpdated', ...
    'Could not find <param.version> in %s.', prjFile);
localWrite(prjFile, newptxt);
fprintf('  DASH.prj -> %s\n', vBare);

% --- 3. Run the test gate ------------------------------------------------
if skipTests
    warning('build_release:skippedTests', ...
        'Skipping the dash.testToolbox gate at user request.');
else
    fprintf('  Running dash.testToolbox (throws on first failure) ...\n');
    returnDir = cd(repo);
    restore   = onCleanup(@() cd(returnDir));   % restore cwd even on error
    rehash;                 % make sure the just-edited files are picked up
    dash.testToolbox;       % silent on success, errors on any failure
    clear restore;          % cd back now, before packaging
    fprintf('  Tests passed.\n');
end

% --- 4. Package the versioned .mltbx -------------------------------------
if ~isfolder(outputDir)
    mkdir(outputDir);
end
mltbxFile = fullfile(outputDir, ['DASH-' vBare '.mltbx']);
matlab.addons.toolbox.packageToolbox(prjFile, mltbxFile);
assert(isfile(mltbxFile), 'build_release:noOutput', ...
    'Packaging did not produce the expected file: %s', mltbxFile);

info = dir(mltbxFile);
fprintf('  Packaged %s (%.1f MB)\n', mltbxFile, info.bytes/1e6);
fprintf('=== Release %s ready ===\n\n', vTag);

end

% -------------------------------------------------------------------------
function localWrite(file, txt)
% Overwrite a text file in place (truncate, no delete) so it works in
% permission-restricted or file-synced folders.
fid = fopen(file, 'w');
assert(fid > 0, 'build_release:cannotWrite', ...
    'Could not open %s for writing.', file);
closeFid = onCleanup(@() fclose(fid));
fwrite(fid, txt);
end
