function[] = tests
%% dash.gridfileSources.tests  Unit tests for the gridfileSources class
% ----------
%   dash.gridfileSources.tests
%   Runs the tests. If successful, exits silently. Otherwise, throws an
%   error at the first failed test.
% ----------
%
% <a href="matlab:dash.doc('dash.gridfileSources.tests')">Documentation Page</a>

% Get path to test data
here = mfilename('fullpath');
folders = strsplit(here, filesep);
dash = folders(1:end-3);
testpath = fullfile(dash{:}, 'testdata','dash','gridfileSources');

% Move to test data
home = pwd;
gohome = onCleanup( @()cd(home) );
cd(testpath);

% Run tests
constructor;
add(testpath);
remove(testpath);
indices(testpath);
unpack(testpath);
build(testpath);
ismatch(testpath);
absolutePaths(testpath);
savePath(testpath);
info(testpath);

end

function[] = constructor
try
    dash.gridfileSources;
catch
    error('constructor');
end
end
function[] = add(testpath)

%% Default gridfile
% Relative paths
% mat / nc / text data sources
% import options
% default transformations

% Get file paths
mat = fullfile(testpath, "test.mat");
nc = fullfile(testpath, "test.nc");
text = fullfile(testpath, "test.txt");
dap = "https://psl.noaa.gov/thredds/dodsC/Datasets/cru/crutem4/var/air.mon.anom.nc";

% Create a default gridfile object
grid = gridfile.new('test.grid', gridMetadata('lat',1), true);

% Data sources
matSource = dash.dataSource.mat(mat, 'a');
ncSource = dash.dataSource.nc(nc, 'a');
textSource = dash.dataSource.text(text, 'NumHeaderLines', 3);
dapSource = dash.dataSource.nc(dap, 'air');

% Example dimension names and sizes
dims = {["lat","lon","time"], ["lev"], ["site","run","site"], ["lev","time","run"]};
saveDims = ["lat,lon,time"; "lev"; "site,run,site"; "lev,time,run"];
size = {[1 2 3], [2 3 1 1], 1, [4 5 6]};
saveSize = ["1,2,3";"2,3,1,1";"1";"4,5,6"];

% Initialize catalogue and add sources
sources = dash.gridfileSources;
sources.gridfile = grid.file;
sources = sources.add(grid, matSource, dims{1}, size{1}, dims{1}, size{1}, size{1});
sources = sources.add(grid, textSource, dims{2}, size{2}, dims{2}, size{2}, size{2});
sources = sources.add(grid, ncSource, dims{3}, size{3}, dims{3}, size{3}, size{3});
sources = sources.add(grid, textSource, dims{2}, size{2}, dims{2}, size{2}, size{2});
sources = sources.add(grid, dapSource, dims{4}, size{4}, dims{4}, size{4}, size{4});

% Check all fields match
assert(isequal(sources.type, ["mat";"text";"nc";"text";"nc"]), 'type');
assert(isequal(sources.source, ["./test.mat";"./test.txt";"./test.nc";"./test.txt";dap]), 'source file');
assert(isequal(sources.relativePath, [true;true;true;true;false]), 'relative path');
assert(isequal(sources.dataType, ["single";"double";"single";"double";"single"]), 'datatype');
assert(isequal(sources.var, ["a";"";"a";"";"air"]), 'var');
assert(isequal(sources.importOptions, {{'NumHeaderLines',3};{'NumHeaderLines',3}}), 'importOptions');
assert(isequal(sources.importOptionSource, [2;4]), 'importOptionSource');
k = [1:3, 2, 4];
assert(isequal(sources.dims, saveDims(k)), 'dims');
assert(isequal(sources.size, saveSize(k)), 'size');
assert(isequal(sources.mergedDims, saveDims(k)), 'merged dims');
assert(isequal(sources.mergedSize, saveSize(k)), 'merged size');
assert(isequal(sources.mergeMap, saveSize(k)), 'merge map');
assert(isequaln(sources.fill, NaN(5,1)), 'fill');
assert(isequaln(sources.range, repmat([-Inf, Inf], 5,1)), 'range');
assert(isequal(sources.transform, repmat("none", 5, 1)), 'transform');
assert(isequaln(sources.transform_params, NaN(5,2)), 'transform params');

%% Absolute paths

grid.absolutePaths(true);
match = [mat;text;nc;text;dap];
for m = 1:numel(match)
    match(m) = dash.file.urlSeparators(match(m));
end

% Initialize catalogue and add sources
sources = dash.gridfileSources;
sources.gridfile = grid.file;
sources = sources.add(grid, matSource, dims{1}, size{1}, dims{1}, size{1}, size{1});
sources = sources.add(grid, textSource, dims{2}, size{2}, dims{2}, size{2}, size{2});
sources = sources.add(grid, ncSource, dims{3}, size{3}, dims{3}, size{3}, size{3});
sources = sources.add(grid, textSource, dims{2}, size{2}, dims{2}, size{2}, size{2});
sources = sources.add(grid, dapSource, dims{4}, size{4}, dims{4}, size{4}, size{4});

% Check source files
assert(isequal(sources.source, match), 'absolute sources');
assert(isequal(sources.relativePath, false(5,1)), 'absolute path');

%% Data transformations

grid.fillValue(5);
grid.validRange([0, 1000]);
grid.transform('linear', [1 2]);

% Initialize catalogue and add sources
sources = dash.gridfileSources;
sources.gridfile = grid.file;
sources = sources.add(grid, matSource, dims{1}, size{1}, dims{1}, size{1}, size{1});
sources = sources.add(grid, textSource, dims{2}, size{2}, dims{2}, size{2}, size{2});
sources = sources.add(grid, ncSource, dims{3}, size{3}, dims{3}, size{3}, size{3});
sources = sources.add(grid, textSource, dims{2}, size{2}, dims{2}, size{2}, size{2});
sources = sources.add(grid, dapSource, dims{4}, size{4}, dims{4}, size{4}, size{4});

% Check values
assert(isequal(sources.fill, repmat(5,5,1)), 'fill');
assert(isequal(sources.range, repmat([0 1000], 5, 1)), 'range');
assert(isequal(sources.transform, repmat("linear",5,1)), 'transform');
assert(isequal(sources.transform_params, repmat([1 2], 5, 1)), 'transform_params');


end
function[] = remove(testpath)

% Get file paths
mat = fullfile(testpath, "test.mat");
nc = fullfile(testpath, "test.nc");
text = fullfile(testpath, "test.txt");
dap = "https://psl.noaa.gov/thredds/dodsC/Datasets/cru/crutem4/var/air.mon.anom.nc";

% Data sources
mat = dash.dataSource.mat(mat, 'a');
nc = dash.dataSource.nc(nc, 'a');
text = dash.dataSource.text(text, 'NumHeaderLines', 3);
dap = dash.dataSource.nc(dap, 'air');

% Create a default gridfile object
grid = gridfile.new('test.grid', gridMetadata('lat',1), true);

% Create sources and output to match
dims = "a";
size = 1;
args = {dims, size, dims, size, size};
sources = dash.gridfileSources;
sources = sources.add(grid, mat, args{:});
sources = sources.add(grid, text, args{:});
sources = sources.add(grid, nc, args{:});
sources = sources.add(grid, text, args{:});
sources = sources.add(grid, dap, args{:});
sources = sources.add(grid, text, args{:});

match = dash.gridfileSources;
match = match.add(grid, mat, args{:});
match = match.add(grid, dap, args{:});
match = match.add(grid, text, args{:});

sources = sources.remove(2:4);

assert(isequaln(sources, match), 'remove');

end
function[] = indices(testpath)

% Get file paths
mat = fullfile(testpath, "test.mat");
text = fullfile(testpath, "test.txt");
nc = fullfile(testpath, "test.nc");
dap = "https://psl.noaa.gov/thredds/dodsC/Datasets/cru/crutem4/var/air.mon.anom.nc";
mat2 = fullfile(testpath, "test2.mat");
notfile = fullfile(testpath, "not-a-file.txt");

tests = {
    % description, should succeed, input, match output
    'indices', true, [1 4 2], [1 4 2]
    'bad indices', false, 7, []
    'names', true, ["test.nc";"test.mat";"test2.mat"], [3;1;6]
    'names without extensions', true, "test2", 6
    'partial path name, url', true, ["dash/gridfileSources/test.nc";"gridfileSources/test2"], [3;6]
    'partial path name, windows', true, ["dash\gridfileSources\test.nc";"gridfileSources\test2"], [3;6]
    'duplicate names', false, "test.txt", []
    'same name, different extension, no user extension', false, "test", []
    'same name, different extensions, user extension', true, ["test.nc";"test.mat"], [3;1]
    'file ends with name but does not match, with extension', false, "est2.mat", []
    'file ends with name but does not match, without extension', false, "est2", []
    'absolute path to relative save', true, [mat;mat2], [1;6]
    'relative path to absolute save', true, "air.mon.anom.nc", 4
    'name does not exist', false, notfile, []
    % 'custom error', tested implicitly
    };
testHeader = 'test:header';
    
% Data sources
matSource = dash.dataSource.mat(mat, 'a');
matSource2 = dash.dataSource.mat(mat2, 'a');
ncSource = dash.dataSource.nc(nc, 'a');
textSource = dash.dataSource.text(text, 'NumHeaderLines', 3);
dapSource = dash.dataSource.nc(dap, 'air');

% Create a default gridfile object
grid = gridfile.new('test.grid', gridMetadata('lat',1), true);

% Build source catalogue
args = {"a",1,"a",1,1};
sources = dash.gridfileSources;
sources = sources.add(grid, matSource, args{:});
sources = sources.add(grid, textSource, args{:});
sources = sources.add(grid, ncSource, args{:});
sources = sources.add(grid, dapSource, args{:});
sources = sources.add(grid, textSource, args{:});
sources = sources.add(grid, matSource2, args{:});

% Run tests
try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                sources.indices(tests{t,3}, testHeader);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, testHeader), 'header');

        else
            s = sources.indices(tests{t,3}, testHeader);
            assert(isequal(s, tests{t,4}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = unpack(testpath)
   
% Get file paths
mat = fullfile(testpath, "test.mat");
text = fullfile(testpath, "test.txt");
nc = fullfile(testpath, "test.nc");

% Data sources
matSource = dash.dataSource.mat(mat, 'a');
ncSource = dash.dataSource.nc(nc, 'a');
textSource = dash.dataSource.text(text, 'NumHeaderLines', 3);

% Create a default gridfile object
grid = gridfile.new('test.grid', gridMetadata('lat',1), true);

% Build source catalogue
inputDims = {["lat","lon","lev"], ["site","time"], ["time","run"]};
inputSize = {[1,4,3,1], [2,4,4], [3 4 2]};
mergeDims = {["site","lev"], "time", ["run","time"]};
mergeSize = {[4 5 1],[2 2 100], [1 1 1]};
mergeKey = {[1 1 2], [1 2 3], [2 1 3 3]};

sources = dash.gridfileSources;
sources = sources.add(grid, matSource, inputDims{1}, inputSize{1}, mergeDims{1}, mergeSize{1}, mergeKey{1});
sources = sources.add(grid, textSource, inputDims{2}, inputSize{2}, mergeDims{2}, mergeSize{2}, mergeKey{2});
sources = sources.add(grid, ncSource, inputDims{3}, inputSize{3}, mergeDims{3}, mergeSize{3}, mergeKey{3});

for k = 1:3
    [dims, size, mergedDims, mergedSize, mergedKey] = sources.unpack(k);
    assert(isequal(dims, inputDims{k}), 'dims');
    assert(isequal(size, inputSize{k}), 'size');
    assert(isequal(mergedDims, mergeDims{k}), 'merged dims');
    assert(isequal(mergedSize, mergeSize{k}), 'merged size');
    assert(isequal(mergedKey, mergeKey{k}), 'merge key');
end

end
function[] = build(testpath)

% Get file paths
mat = fullfile(testpath, "test.mat");
text = fullfile(testpath, "test.txt");
nc = fullfile(testpath, "test.nc");
text2 = fullfile(testpath, 'other-path', 'test.txt');

% Data sources
matSource = dash.dataSource.mat(mat, 'a');
ncSource = dash.dataSource.nc(nc, 'a');
textSource = dash.dataSource.text(text, 'NumHeaderLines', 3);
text2Source = dash.dataSource.text(text2, 'NumHeaderLines',3);

% Create a default gridfile object
grid = gridfile.new('test.grid', gridMetadata('lat',1), true);
args = {"a",1,"a",1,1};
sources = dash.gridfileSources;
sources = sources.add(grid, matSource, args{:});
sources = sources.add(grid, textSource, args{:});
sources = sources.add(grid, ncSource, args{:});

tests = {
    % description, index, filepath
    'mat', 1, {}, matSource
    'text', 2, {}, textSource
    'nc', 3, {}, ncSource
    'other path', 2, text2, text2Source
    };

try
    for t = 1:size(tests,1)
        if isempty(tests{t,3})
            dataSource = sources.build(tests{t,2});
        else
            dataSource = sources.build(tests{t,2:3});
        end
        props = string(properties(tests{t,4}));
        for p = 1:numel(props)
            if ~strcmp(props(p), 'm')
                assert(isequal(tests{t,4}.(props(p)), dataSource.(props(p))), 'output');
            end
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = ismatch(testpath)

% Get file paths
mat = fullfile(testpath, "test.mat");
text = fullfile(testpath, "test.txt");
moved = fullfile(testpath, 'other-path', 'test.txt');
changeSize = fullfile(testpath, 'other-path', 'test-changed-size.txt');
changeType = fullfile(testpath, 'other-path', 'test-changed-type.mat');

% Data sources
mat = dash.dataSource.mat(mat, 'a');
text = dash.dataSource.text(text, 'NumHeaderLines', 3);
moved = dash.dataSource.text(moved, 'NumHeaderLines', 3);
changeSize = dash.dataSource.text(changeSize, 'NumHeaderLines',3);
changeType = dash.dataSource.mat(changeType, 'a');

tests = {
    % description, datasource, index, match output
    'exact match', mat, 1, {true, [], [], []}
    'moved file', moved, 2, {true, [], [], []}
    'different type', changeType, 1, {false, 'type', 'double','single'}
    'different size', changeSize, 2 {false, 'size', "6x3", "7x4"}
    };

% Build sources
grid = gridfile.new('test.grid', gridMetadata('lat',1), true);
sources = dash.gridfileSources;
sources = sources.add(grid, mat,["a","b","c"], [100 20 5], "a", 1, 1);
sources = sources.add(grid, text, ["a","b"], [7,4], "a", 1, 1);

% Run tests
try
    for t = 1:size(tests,1)
        [tf, prop, objval, catval] = sources.ismatch(tests{t,2:3});
        assert(isequal(tests{t,4}{1}, tf), 'tf');
        assert(isequal(tests{t,4}{2}, prop), 'prop');
        assert(isequal(tests{t,4}{3}, objval), 'new object value');
        assert(isequal(tests{t,4}{4}, catval), 'catalogued value');
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = absolutePaths(testpath)

% Get files
mat = fullfile(testpath, "test.mat");
text = fullfile(testpath, "test.txt");
nc = fullfile(testpath, "test.nc");
dap = "https://psl.noaa.gov/thredds/dodsC/Datasets/cru/crutem4/var/air.mon.anom.nc";

% Data sources
matSource = dash.dataSource.mat(mat, 'a');
ncSource = dash.dataSource.nc(nc, 'a');
textSource = dash.dataSource.text(text, 'NumHeaderLines', 3);
dapSource = dash.dataSource.nc(dap, 'air');

% Build source catalogue
grid = gridfile.new('test.grid', gridMetadata('lat',1), true);
args = {"a",1,"a",1,1};
sources = dash.gridfileSources;
sources = sources.add(grid, matSource, args{:});
sources = sources.add(grid, textSource, args{:});
sources = sources.add(grid, ncSource, args{:});
sources = sources.add(grid, dapSource, args{:});

% Use URL separators
mat = dash.file.urlSeparators(mat);
text = dash.file.urlSeparators(text);
nc = dash.file.urlSeparators(nc);

% All paths
paths = sources.absolutePaths;
assert(isequal(paths, [mat;text;nc;dap]), 'all paths');

% Indexed paths
paths = sources.absolutePaths([3 1 4 4 2 1]);
assert(isequal(paths, [nc;mat;dap;dap;text;mat]), 'indexed paths');

end
function[] = savePath(testpath)

% Get files
mat = fullfile(testpath, "test.mat");
text = fullfile(testpath, "test.txt");
nc = fullfile(testpath, "test.nc");
dap = "https://psl.noaa.gov/thredds/dodsC/Datasets/cru/crutem4/var/air.mon.anom.nc";
grid = fullfile(testpath, 'test.grid');

% Use URL separators
mat = dash.file.urlSeparators(mat);
text = dash.file.urlSeparators(text);
nc = dash.file.urlSeparators(nc);
grid = dash.file.urlSeparators(grid);

% Data sources
matSource = dash.dataSource.mat(mat, 'a');
textSource = dash.dataSource.text(text, 'NumHeaderLines', 3);
dapSource = dash.dataSource.nc(dap, 'air');

% Initialize sources
sources = dash.gridfileSources;
sources.gridfile = grid;

% Run tests
tests = {
    % description, dataSource, try relative, index, match sources
    'new path, absolute', matSource, false, [], mat
    'new path, try relative, use absolute', dapSource, true, [], [mat;dap]
    'new path, relative', textSource, true, [], [mat;dap;"./test.txt"]
    'update path, absolute', textSource, false, 3, [mat;dap;text]
    'update path, try relative, use absolute', dapSource, true, 2, [mat;dap;text]
    'update path, relative', matSource, true, 1, ["./test.mat";dap;text]
    };

try
    for t = 1:size(tests,1)
        if isempty(tests{t,4})
            sources = sources.savePath(tests{t,2:3});
        else
            sources = sources.savePath(tests{t,2:4});
        end
        assert(isequal(sources.source, tests{t,5}), 'output');
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = info(testpath)

ncfile = fullfile(testpath, 'test.nc');
ncfile = dash.file.urlSeparators(ncfile);
textfile = fullfile(testpath, 'test.txt');
textfile = dash.file.urlSeparators(textfile);

ncSource = dash.dataSource.nc(ncfile, 'a');
textSource = dash.dataSource.text(textfile, "NumHeaderLines", 3);

grid = gridfile.new('test.grid',gridMetadata('lat',1), true);
grid.fillValue(5);
grid.validRange([0 1000]);
grid.transform('linear', [1 2]);

args = {"a",1,"a",1,1};
sources = dash.gridfileSources;
sources.gridfile = grid.file;
sources = sources.add(grid, ncSource, args{:});
sources = sources.add(grid, textSource, args{:});

nc = struct('parent', grid.file, 'index', 1, 'name', "test.nc", ...
    'file', ncfile, 'file_type', 'NetCDF', 'path', sources.source(1), 'uses_relative_path', true,...
    'variable','a', 'import_options',[], 'data_type','single', 'dimensions', "a", 'size', 1,...
    'fill_value', 5, 'valid_range', [0 1000], 'transform','linear','transform_parameters', [1 2],...
    'raw_dimensions', "a", 'raw_size', 1);

text = struct('parent',grid.file,'index',2,'name',"test.txt",...
    'file',textfile,'file_type','Delimited text','path',sources.source(2),'uses_relative_path',true,...
    'variable',"",'import_options',[],'data_type','double','dimensions',"a",'size',1,...
    'fill_value',5,'valid_range',[0 1000],'transform','linear','transform_parameters',[1 2],...
    'raw_dimensions','a','raw_size',1);
text.import_options = {"NumHeaderLines", 3};

info = sources.info([2 1 1]);
assert(isequaln(info, [text;nc;nc]), 'indexed sources');

end