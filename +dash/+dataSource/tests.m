function[] = tests
%% dash.dataSource.tests  Unit tests for classes in the dash.dataSource package
% ----------
%   dash.dataSource.tests
%   Runs the tests. If successful, exits silently. Otherwise, throws an
%   error message at the first failed test.
% ----------
%
% <a href="matlab:dash.doc('dash.dataSource.tests')">Documentation Page</a>

% Path to test data
here = mfilename('fullpath');
folders = strsplit(here, filesep);
dash = folders(1:end-3);
testpath = fullfile(dash{:}, 'testdata','dash','dataSource');

% Run tests
matconstructor(testpath);
matload(testpath);
mattoggle;

ncconstructor(testpath);
ncload(testpath);

textconstructor(testpath)
textload(testpath);

end

function[] = matconstructor(testpath)

% Get test files
file = fullfile(testpath, 'test-v73.mat');
oldmatfile = fullfile(testpath, 'test-v7.mat');
ncfile = fullfile(testpath, 'trailing-singleton.nc');
warning('clear warnings');
clc;

tests = {
    % description, fail, file, variable, check warning
    'mat file', true, file, "a", false
    'old version matfile', true, oldmatfile, "a", true
    'not mat file', false, ncfile, "testVariable", false
    'missing variable', false, file, "b", false
    'empty variable', false, file, 'empty', false
    };


for t = 1:size(tests,1)
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            dash.dataSource.mat(tests{t,3}, tests{t,4});
        catch ME
        end
        assert(contains(ME.identifier, 'DASH:dataSource'), tests{t,1});
        
    else
        warning('clear warnings');
        clc;
        mat = dash.dataSource.mat(tests{t,3}, tests{t,4});
        clc
        m = matfile(tests{t,3});
        info = whos(m,'a');

        assert(...
               isequal(mat.var, tests{t,4})...
            && isequal(mat.source, tests{t,3})...
            && isequal(mat.dataType, info.class)...
            && isequal(mat.size, info.size), tests{t,1});
        
        if tests{t,5}
            [~, warnid] = lastwarn;
            assert(contains(warnid, 'DASH:dataSource:mat'), tests{t,1});
        end
    end
end

end
function[] = matload(testpath)

% Get test files
file = fullfile(testpath, 'test-v73.mat');
oldfile = fullfile(testpath, 'test-v7.mat');
tsfile = fullfile(testpath, 'trailing-singleton.mat');
reset = dash.dataSource.mat.toggleWarning('error');

tests = {
    % description, file, variable, indices
    'mat file', file, "a", {[1 17 2]', [2 9 3]', [3 1]'}
    'old format mat file',  oldfile, "a", {[1 17 2]', [2 9 3]', [3 1]'}
    'trailing singletons', tsfile, "a", {[1 44 67 2 19 3]'}
    };

for t = 1:size(tests,1)
    source = dash.dataSource.mat(tests{t,2}, tests{t,3});
    clc;
    Xsource = source.load(tests{t,4});
   
    m = matfile(tests{t,2});
    X = m.(tests{t,3});
    X = X(tests{t,4}{:});
    
    assert(isequal(X, Xsource), tests{t,1});
    assert(isequal(class(Xsource), source.dataType), tests{t,1});
end

end
function[] = mattoggle

id = 'MATLAB:MatFile:OlderFormat';

tests = {
    % description/warning state
    'on'
    'off'
    'error'
    };

initial = warning('query',id);

for t = 1:size(tests,1)
    reset = dash.dataSource.mat.toggleWarning(tests{t,1});
    current = warning('query',id);
    assert(isequal(current.state, tests{t,1}), tests{t,1});
    clearvars reset
    current = warning('query',id);
    assert(isequal(current.state, initial.state), tests{t,1});
end

end
function[] = ncconstructor(testpath)

% Get test NetCDF file
folders = strsplit(testpath, filesep);
ncfile = fullfile(folders{1:end-2}, 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PRECC.185001-200512.nc');
mat_file = fullfile(testpath, 'test.mat');
opendap = 'https://psl.noaa.gov/thredds/dodsC/Datasets/cru/crutem4/var/air.mon.anom.nc';

tests = {
    % description, should succeed, file, variable
    'nc file', true, ncfile, "PRECC"
    'opendap', true, opendap, "air"
    'not nc file', false, mat_file, "PRECC"
    'missing variable', false, ncfile, 'NotAVariable'
    };

for t = 1:size(tests,1)
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            dash.dataSource.nc(tests{t,3}, tests{t,4});
        catch ME
        end
        assert(contains(ME.identifier, 'DASH:dataSource'), tests{t,1});
        
    else
        nc = dash.dataSource.nc(tests{t,3}, tests{t,4});
        info = ncinfo(tests{t,3}, tests{t,4});
        assert(...
               isequal(nc.var, tests{t,4})...
            && isequal(nc.source, tests{t,3})...
            && isequal(nc.dataType, info.Datatype)...
            && isequal(nc.size, info.Size), tests{t,1});
    end
end

end
function[] = ncload(testpath)

folders = strsplit(testpath, filesep);
ncfile = fullfile(folders{1:end-2}, 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PRECC.185001-200512.nc');
opendap = 'https://psl.noaa.gov/thredds/dodsC/Datasets/cru/crutem4/var/air.mon.anom.nc';
tsfile = fullfile(testpath, 'trailing-singleton.nc');

tests = {
    % description, file, variable, indices
    'local file', ncfile, 'PRECC', {(1:4:144)', [1 17 3 90 27]', [1800:1860, 1872]'}
    'opendap', opendap, 'air', {[1 6 19 2 20]', [13 19 18]', [5:6:70, 92]'}
    'trailing singleton dimensions', tsfile, 'testVariable', {[4 19 3]'}
    };

for t = 1:size(tests,1)
    source = dash.dataSource.nc(tests{t,2}, tests{t,3});
    Xsource = source.load(tests{t,4});
    
    X = ncread(tests{t,2}, tests{t,3});
    X = X(tests{t,4}{:});
    
    assert(isequal(X, Xsource), tests{t,1});
    assert(isequal(class(Xsource), source.dataType), tests{t,1});
end

end
function[] = textconstructor(testpath)

file = fullfile(testpath, 'test.txt');
notfile = fullfile(testpath, 'test-v7.mat');
emptyfile = fullfile(testpath, 'empty.txt');

tests = {
    % description, should succeed, file, import options
    'no options', true, file, {}
    'name, value', true, file, {'NumHeaderLines', 3}
    'import options', true, file, {delimitedTextImportOptions('Delimiter',',')}
    'invalid file', false, notfile, {}
    'invalid options', false, file, {5}
    'empty', false, emptyfile, {}
    };

for t = 1:size(tests,1)
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            dash.dataSource.text(tests{t,3}, tests{t,4}{:});
        catch ME
        end
        assert(contains(ME.identifier, 'DASH:dataSource'));
        
    else
        source = dash.dataSource.text(tests{t,3}, tests{t,4}{:});
        X = readmatrix(tests{t,3}, tests{t,4}{:});
        siz = size(X);
        type = class(X);
        
        assert(    isequaln(source.importOptions, tests{t,4})...
                && isequal(source.source, tests{t,3})...
                && isequal(source.dataType, type)...
                && isequal(source.size, siz), tests{t,1});
    end
end

end
function[] = textload(testpath)

file = fullfile(testpath, 'test.txt');

tests = {
    % description, file, import options, indices
    'no options', file, {}, {[1 6 2]', [4 3]'}
    'name, value', file, {'NumHeaderLines', 3}, {[1 6 2]', [4 3]'}
    'import options', file, {delimitedTextImportOptions('Delimiter',',')}, {[1 6 2]', [4 3]'}
    };

for t = 1:size(tests,1)
    source = dash.dataSource.text(tests{t,2}, tests{t,3}{:});
    Xsource = source.load(tests{t,4});
    X = readmatrix(tests{t,2}, tests{t,3}{:});
    X = X(tests{t,4}{:});
    assert(isequal(X, Xsource), tests{t,1});
    assert(isequal(source.dataType, class(Xsource)), tests{t,1});
end

end