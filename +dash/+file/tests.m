function[] = tests
%% dash.file.tests  Implement unit-tests for the dash.file package
% ----------
%   dash.file.tests
%   Runs the tests
% ----------
%

% Locate test data
here = mfilename('fullpath');
folders = strsplit(here, filesep);
dash = folders(1:end-3);
testpath = fullfile(dash{:}, 'testdata','dash','file');

% Run tests
new(testpath);
collapsePath;
relativePath;
urlSeparators;

end

function[] = new(testpath)

% Move to test data
home = pwd;
gohome = onCleanup( @()cd(home) );
testFolder = fullfile(testpath, 'current');
cd(testFolder);

% Add to path
onpath = fullfile(testpath, 'on-path');
addpath(genpath(testpath));
rmpath(genpath(testpath));
addpath(onpath);
removeTests = onCleanup( @()rmpath(onpath) );

% Get file paths
notexist = fullfile(testpath, 'not-a-file.txt');
abspath = fullfile(testpath, 'on-path', 'test-file.txt');
relpath = '../on-path/test-file.txt';
current = 'test-file.txt';
noext = fullfile(testpath, 'on-path', 'test-file');

tests = {
    % description, path, ext, overwrite, should fail, output path
    'file does not exist', notexist, [], false, false, notexist;
    'absolute path exists', abspath, [], true, false, abspath;
    'relative path exists', relpath, [], true, false, relpath;
    'file exists off path in current folder', current, [], true, false, current;
    'file exists with extension', noext, '.txt', true, false, abspath;
    'file exists, overwrite not allowed', abspath, [], false, true, [];
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    try 
        output = dash.file.new(tests{t,2}, tests{t,3}, tests{t,4}, testHeader);
    catch ME
    end
    
    shouldFail = tests{t,5};
    if shouldFail
        condition = contains(ME.identifier, testHeader);
    else
        condition = isequal(output, tests{t,6});
    end
    assert(condition, tests{t,1});
end
    
end
function[] = collapsePath

tests = {
    % description, path, output
    'path with .', 'a/path/./with/./elements', 'a/path/with/elements';
    'path with ..', 'a/path/with/../two/dot/../elements', 'a/path/two/elements';
    'path with nested ..', 'a/path/with/nested/../../elements', 'a/path/elements';
    'path with . and ..', 'a/./path/with/../and/./other/../../dots', 'a/path/dots';
    'string path', "a/./path/with/../and/./other/../../dots", "a/path/dots";
    'windows separators', 'a\.\path\with\..\and\.\other\..\..\dots', 'a/path/dots'
    };

for t = 1:size(tests,1)
    output = dash.file.collapsePath(tests{t,2});
    assert(isequal(output, tests{t,3}), tests{t,1});
end

end
function[] = relativePath

tests = {
    % description, file, folder, output path, is relative
    'file below folder', 'path/to/folder/with/file', 'path/to/folder', './with/file', true;
    'file above folder', 'path/to/file', 'path/to/a/folder', './../../file', true;
    'file branches from folder', 'path/to/a/certain/file', 'path/to/a/different/folder', './../../certain/file', true;
    'file and folder on different drives', 'path/to/a/file', 'different/drive/folder', 'path/to/a/file', false;
    'windows separators', 'path\to\file', 'path\to\folder', './../file', true;
    "string paths", 'path/to/file', 'path/to/folder', './../file', true;
    };

for t = 1:size(tests, 1)
    [output, isrelative] = dash.file.relativePath(tests{t,2}, tests{t,3});
    assert(isequal(output, tests{t,4}) && isequal(isrelative, tests{t,5}), tests{t,1});    
end

end
function[] = urlSeparators

tests = {
    'a/url/char', 'a/url/char', 'char url';
    "a/string/url", "a/string/url", "string url";
    'a\windows\char', 'a/windows/char', 'windows char';
    "a\windows\string", "a/windows/string", 'windows url';
    };

for t = 1:size(tests,1)
    output = dash.file.urlSeparators(tests{t,1});
    assert(isequal(output, tests{t,2}), tests{t,3});
end

end