function[] = tests

% Move to test folder
here = mfilename('fullpath');
folders = strsplit(here, filesep);
dash = folders(1:end-2);
testpath = fullfile(dash{:}, 'testdata', 'gridfile');

home = pwd;
gohome = onCleanup( @()cd(home) );
cd(testpath);


%%% Current test
loadInternal;


% Run the tests
new;
constructor;
update;
save_;

metadata;
edit_;
expand;
addDimension;

addAttributes;
removeAttributes;
editAttributes;

add;
remove;
rename
absolutePaths

fillValue;  % these only check that gridfile properties are updated
validRange; % check the actual implementation in the tests for "load"
transform;

getLoadIndices;
sourcesForLoad;
buildSources;
loadInternal;
load_;

plus;
minus;
times;
divide;
arithmetic;

sources;
info;
name;
disp;
dispSources;

end

function[] = new

file = fullfile(pwd, 'test.grid');
exists = fullfile(pwd, 'already-exists.grid');
noext = fullfile(pwd, 'test');

atts = struct('Units', "Kelvin");
meta = gridMetadata("site", (1:5)', "time", (1900:2000)','attributes', atts);
meta2 = meta.setOrder(["time","site"]);

file = dash.file.urlSeparators(file);
sources = dash.gridfileSources;
sources.gridfile = string(file);

tests = {
    'new file', true, file, meta, [], false
    'not filename', false, 5, meta, [], false
    'not metadata', false, file, struct('lat',(1:90)', 'lon',5), [], false
    'no overwrite 1', false, exists, gridMetadata, [], false
    'no overwrite 2', false, exists, gridMetadata, false, false
    'overwrite', true, file, meta, true, true
    'append extension', true, noext, meta, [], false
    'remove dimension order', true, file, meta2, [], false
    };
header = "DASH:gridfile:new";


try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                gridfile.new(tests{t,3:5});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'incorrect error');
            
        else
            if isfile(file)
                delete(file);
            end
            if tests{t,6}
                gridfile.new(file, gridMetadata);
            end
            
            grid = gridfile.new(tests{t,3:5});
            
            assert(isa(grid, 'gridfile'), 'object');
            assert(isscalar(grid), 'scalar');
            assert(strcmp(grid.file, file), 'file');
            assert(isequal(grid.dims, ["site","time"]), 'dims');
            assert(isequal(grid.size, [5 101]), 'size');
            assert(isequal(grid.meta, meta), 'meta');
            assert(isequaln(grid.fill, NaN), 'fill');
            assert(isequaln(grid.range, [-Inf Inf]), 'range');
            assert(strcmp(grid.transform_, "none"), 'transform');
            assert(isequaln(grid.transform_params, [NaN NaN]), 'transform params');
            assert(grid.nSource==0, 'nSource');
            assert(isequal(grid.dimLimit, zeros(2,2,0)), 'dimLimit');
            assert(grid.relativePath, 'relativePath');
            assert(isequal(grid.sources_, sources), 'sources');
            assert(isfile(file), 'file exists');
        end
    end
            
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = constructor

file = fullfile(pwd, 'test.grid');
noext = fullfile(pwd, 'test');
othertype = fullfile(pwd, 'test.txt');
missing = fullfile(pwd, 'not-a-file.grid');
invalid = fullfile(pwd, 'not-valid.grid');

tests = {
    'build gridfile', true, file
    'add extension', true, noext
    'not a .grid file', false, othertype
    'file does not exist', false, missing
    'invalid .grid file', false, invalid
    };
header = "DASH:gridfile";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                gridfile(tests{t,3});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            if isfile(file)
                delete(file);
            end
            grid1 = gridfile.new(file, gridMetadata('site',(1:5)', 'time', (1900:2000)'));
            
            grid2 = gridfile(tests{t,3});
            assert(isequaln(grid1, grid2), 'output');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = update

%% Update property
file = dash.file.urlSeparators(fullfile(pwd, 'test.grid'));
meta = gridMetadata('lat', (-90:90)', 'lon', (1:360)');
grid = gridfile.new('test.grid', meta, true);
m = matfile('test.grid', 'Writable', true);
m.dims = ["lon","lat","time"];
grid.update;
assert(isequal(grid.dims, ["lon","lat","time"]), 'update property');
assert(isequal(grid.sources_.gridfile, file), 'copy filename to sources');

%% Missing field
s = struct(m);clc;
s = rmfield(s, ["Properties", "dims"]);
save('test.grid', '-struct', 's', '-mat'); 
try
    grid.update;
    error('missing field did not fail');
catch ME
    assert(contains(ME.identifier, 'DASH'));
end

%% Invalid mat file
grid.file = "test.mat";
try
    grid.update;
    error('invalid file did not fail');
catch ME
    assert(contains(ME.identifier, 'DASH'));
end

end
function[] = save_

%% Save a changed property
meta = gridMetadata('lat', (-90:90)', 'lon', (1:360)');
grid = gridfile.new('test.grid', meta, true);
grid.dims = ["lon","lat","time"];
grid.save;
m = matfile('test.grid');
assert(isequal(m.dims, ["lon","lat","time"]), 'updated file');
sources = m.sources_;
assert(isequal(sources.gridfile, ""), 'strip path from sources');

end

function[] = metadata

lat = (1:200)';
lon = (1:20)';
run = (1:15)';

meta = gridMetadata('lat', lat, 'lon', lon, 'run', run);
s1 = meta.index('lat', 1:100, 'run', 1:5);
s2 = meta.index('lat', 1:100, 'run', 6:10);
s3 = meta.index('lat', 101:200, 'run', 11:15);

tests = {
    'all metadata 1', [], meta
    'all metadata 2', 0, meta
    'indexed sources', [3 1 1], [s3;s1;s1]
    'all sources', -1, [s1;s2;s3]
    };

file = fullfile(pwd, 'test.grid');
grid = gridfile.new(file, meta, true);
grid.add('mat','test', 'a', ["lat","lon","run"], s1);
grid.add('mat','test', 'a', ["lat","lon","run"], s2);
grid.add('mat','test', 'a', ["lat","lon","run"], s3);

try
    for t = 1:size(tests,1)
        if isempty(tests{t,2})
            output = grid.metadata;
        else
            output = grid.metadata(tests{t,2});
        end
        assert(isequal(output, tests{t,3}), 'output 1');
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = edit_

file = fullfile(pwd, 'test.grid');
atts = struct('a',1,'b',2);
meta = gridMetadata('site', (1:10)', 'time', (1900:2000)', 'attributes', atts);
edit1 = meta.edit('time', (900:1000)');
edit2 = meta.edit('time', (datetime(1900,1,1):calyears(1):datetime(2000,1,1))');
edit3 = meta.edit('site', [(1:10)', (101:110)']);
edit4 = meta.edit('attributes', struct('c',3));

tests = {
    'edit values', true, 'time', (900:1000)', edit1
    'different type', true, 'time', (datetime(1900,1,1):calyears(1):datetime(2000,1,1))', edit2
    'different columns', true, 'site', [(1:10)', (101:110)'], edit3
    'attributes', true, 'attributes', struct('c',3), edit4
    'not a dimension', false, 'not-dimension', 5, []
    'supported dimension not in gridfile', false, 'lon', 5, []
    'different number of rows', false, 'site', (1:11)', []
    'invalid attributes', false, 'attributes', 5, []
    'invalid metadata', false, 'site', {1,2,3,4,5,6,7,8,9,10}, []
    };
header = "DASH";

try
    for t = 1:size(tests,1)
        grid = gridfile.new(file, meta, true);
        
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.edit(tests{t,3:4});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            grid.edit(tests{t,3:4});
            out1 = grid.metadata;
            grid = gridfile(file);
            out2 = grid.metadata;
            
            assert(isequal(out1, tests{t,5}), 'output1');
            assert(isequal(out2, tests{t,5}), 'output2');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = expand

meta = gridMetadata('site', (1:10)', 'time', (1900:2000)');

tests = {
    'expand', true, 'site', (11:15)'
    'undefined dimension', false, 'lat', (1:5)'
    'different columns', false, 'site', [11 12]
    'repeated rows', false, 'site', [11;12;1;14]
    'unappendable type', false, 'site', "site 11"
    };
header = "DASH:gridfile:expand";


try
    for t = 1:size(tests,1)
        grid = gridfile.new('test.grid', meta, true);

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.expand(tests{t,3:4});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            dim = tests{t,3};
            meta2 = meta.edit(dim, cat(1, meta.(dim), tests{t,4}));
            grid.expand(tests{t,3:4});
            grid2 = gridfile('test.grid');
            
            assert(isequal(grid.metadata, meta2), 'metadata1');
            assert(isequal(grid2.metadata, meta2), 'metadata2');
            assert(isequal(grid.size(1), size(meta2.(dim),1)), 'size1');
            assert(isequal(grid2.size(1), size(meta2.(dim),1)), 'size2');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end








end
function[] = addDimension

tests = {
    'new dimension', true, 'run', 1
    'existing dimension', false, 'time', 2001
    'unsupported dimension', false, 'invalid', 5
    'attributes', false, 'attributes', struct('a',1)
    'invalid metadata', false, 'run', {1}
    'metadata with multiple rows', false, 'run', [1;2]
    };
header = "DASH";

meta = gridMetadata('lat', (-90:90)', 'lon', (1:360)', 'time', (1900:2000)');

try
    for t = 1:size(tests,1)
        grid = gridfile.new('test.grid', meta, true);
        
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.addDimension(tests{t,3:4});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            grid.addDimension(tests{t,3:4});
            grid2 = gridfile('test.grid');
            meta2 = meta.edit(tests{t,3:4});

            assert(isequal(grid.dims, ["lon","lat","time","run"]), 'dims1');
            assert(isequal(grid2.dims, ["lon","lat","time","run"]), 'dims2');
            assert(isequal(grid.size, [360 181 101 1]), 'size1');
            assert(isequal(grid.size, [360 181 101 1]), 'size2');
            assert(isequal(grid.metadata, meta2), 'metadata1');
            assert(isequal(grid2.metadata, meta2), 'metadata2');
            assert(isequal(grid.dimLimit, NaN(4,2,0)), 'dimLimit1');
            assert(isequal(grid2.dimLimit, NaN(4,2,0)), 'dimLimit2');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = addAttributes

s = struct('a',1,'b',2,'c',3);
file = fullfile(pwd, 'test.grid');
meta = gridMetadata('site',(1:5)', 'attributes', struct('a',1));
grid = gridfile.new(file, meta, true);

tests = {
    % description, should succeed, inputs
    'add attributes', true, {'b',2,'c',3}
    'existing field',false, {'a',5}
    'invalid field name',false, {'?asdf', 5}
    'invalid name,value pairs',false, {4,5,6}
    };
header = "DASH:gridMetadata:addAttributes";


try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.addAttributes(tests{t,3}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            grid.addAttributes(tests{t,3}{:});
            assert(isequal(grid.metadata.attributes, s), tests{t,1});
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = removeAttributes

file = fullfile(pwd, 'test.grid');
atts = struct('a',1,'b',2,'c',3);
onlyc = struct('c',3);

tests = {
    % inputs, should succed, initial attributes, remove fields, match output
    'syntax 1', true, atts, {["a","b"]}, onlyc
    'syntax 2', true, atts, {'a','b'}, onlyc
    'remove all', true, atts, {0}, struct
    'remove all with no attributes', true, struct, {0}, struct
    'repeat dimensions', true, atts, {'a','a','b'}, onlyc
    'not an attribute', false, atts, {'d'}, []
    };
header = "DASH:gridMetadata:removeAttributes";


try
    for t = 1:size(tests,1)
        meta = gridMetadata('site',(1:5)', 'attributes', tests{t,3});
        grid = gridfile.new(file, meta, true);
        
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.removeAttributes(tests{t,4}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            grid.removeAttributes(tests{t,4}{:});
            assert(isequal(grid.metadata.attributes, tests{t,5}), tests{t,1});
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = editAttributes

file = fullfile(pwd, 'test.grid');
atts = struct('a',1,'b',2,'c',3);
edited = struct('a',1,'b',5,'c',6);

tests = {
    % description, should succeed, inputs
    'edit', true, {'c',6,'b',5}
    'not an attribute', false, {'d',5}
    'repeat dimension', false, {'b',5,'b',5}
    };
header = 'DASH:gridMetadata:editAttributes';

try
    for t = 1:size(tests,1)
        meta = gridMetadata('site',(1:5)', 'attributes', atts);
        grid = gridfile.new(file, meta, true); 
        
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.editAttributes(tests{t,3}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            grid.editAttributes(tests{t,3}{:});
            assert(isequal(grid.metadata.attributes, edited), 'output');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = add

% File paths
opendap = 'https://psl.noaa.gov/thredds/dodsC/Datasets/cru/crutem4/var/air.mon.anom.nc';
notfile = fullfile(pwd, 'not-a-file.mat');

% Metadata for tests
dapMeta = gridMetadata('lon',(1:72)', 'lat', (1:36)', 'time', (1:2063)');
standardMeta = gridMetadata('lat',(6:10)', 'lon', (2:16)', 'time', (1:20)');
singletonMeta = gridMetadata('time',5, 'lat', (6:10)', 'lon', (2:16)');
scalarMeta = gridMetadata('time', 5,'lat',1,'lon',1);
vectorMeta = gridMetadata('time', (1:5)','lat',1,'lon',1);
textMeta = gridMetadata('lat',(1:7)', 'lon', (1:4)','time',1);
notInGrid = gridMetadata('site',(1:5)', 'lon',(1:15)', 'time', (1:20)');
mergeMeta = gridMetadata('lat',(1:4)', 'lon',(1:18)', 'time', (1:3)');

% Output of gridfile properties
stanOut = {1, [2 16;6 10;1 20;1 1]};
dapOut = {1, [1 72;1 36;1 2063;1 1]};
singleOut = {1, [2 16;6 10;5 5;1 1]};
textOut = {1, [1 4;1 7;1 1;1 1]};
vectorOut = {1, [1 1;1 1;1 5;1 1]};
mergeOut = {1, [1 18;1 4;1 3;1 1]};

% gridfileSources output
stanSourceOut = {'type','nc','dataType','double','var','standard',...
    'importOptions', cell(0,1), 'importOptionSource', [], 'dims', "lat,lon,time", 'size', "5,15,20",...
    'mergedDims', "lat,lon,time", 'mergedSize', "5,15,20", 'mergeMap', "1,2,3"};
tsSourceOut = {'dims', "time,lat,lon", 'size', "1,5,15", 'mergedDims', "time,lat,lon", 'mergedSize', "1,5,15", 'mergeMap', "1,2,3"};
singSourceOut = [{'type','nc','dataType','double','var','singletons',...
    'importOptions', cell(0,1), 'importOptionSource', []}, tsSourceOut];

tests = {
    % Standard operation
    'netcdf', true, 1, {'netcdf','test-add','standard', ["lat","lon","time"], standardMeta}, stanOut, {'type', 'nc'}
    'nc', true, 1, {'nc', 'test-add', 'standard', ["lat","lon","time"], standardMeta}, stanOut, stanSourceOut
    'opendap', true, 1, {'nc', opendap, 'air', ["lon","lat","time"], dapMeta}, dapOut, {'type', 'nc'}
    'mat', true, 1, {'mat','test-add', 'standard', ["lat","lon","time"], standardMeta}, stanOut, []
    'txt', true, 1, {'txt', 'test-noheader.txt', ["lat","lon"], textMeta}, textOut, {'importOptions', cell(0,1), 'importOptionSource', []}
    'text', true, 1, {'text', 'test-noheader.txt', ["lat","lon"], textMeta}, textOut, {'importOptions', cell(0,1), 'importOptionSource', []}
    'text, options', true, 1, {'text', 'test.txt', ["lat","lon"], textMeta, 'NumHeaderLines', 3}, textOut, {'importOptions', {{'NumHeaderLines',3}}, 'importOptionSource', 1}
    'missing file', false, 1, {'mat',notfile,'A',["lat","lon","time"], standardMeta}, [], []
    'incompatible data type', false, 1, {'mat','test-add','incompatible',["lat","lon","time"],standardMeta}, [], []

    % NetCDF data sources
    'netcdf, unnamed defined ts', true, 1, {'nc','test-add','singletons',["time","lat","lon"],singletonMeta}, singleOut, singSourceOut
    'netcdf, named undefined ts', true, 1, {'nc', 'test-add','standard',["lat","lon","time","run"], standardMeta.edit('run',4)}, stanOut, stanSourceOut
    'netcdf, missing variable', false, 1, {'nc', 'test-add', 'missing', "time", vectorMeta}, [], []

    % MAT data sources
    'mat, missing variable', false, 1, {'mat', 'test-add', 'missing', "time", vectorMeta}, [], []
    'mat, named ts', true, 1, {'mat', 'test-add', 'standard', ["lat","lon","time","run"], standardMeta.edit('run',4)}, stanOut, []

    % Dimensions
    'unsupported dimension', false, 1, {'mat', 'test-add', 'standard', ["foo","bar","baz"], standardMeta}, [], []
    'supported dimension, but undefined in grid', false, 1, {'mat','test-add','standard',["site","lon","time"],notInGrid}, [], []
    'singleton source dimension not in gridfile', true, 1, {'mat','test-add', 'singletons', ["site","lat","lon"], singletonMeta}, singleOut, {'dims',"site,lat,lon",'size',"1,5,15",'mergedDims',"site,lat,lon",'mergedSize',"1,5,15",'mergeMap',"1,2,3"}

    'unnamed source dimension', false, 1, {'mat', 'test-add','standard', ["lat","lon"], standardMeta.edit('time',[])}, [], []
    'unnamed singleton source dimension', false, 1, {'mat','test-add','singletons',["lat","lon"], singletonMeta.edit('time',[])}, [], []
    'unnamed trailing source dimension', true, 1, {'nc', 'test-add', 'singletons', ["time","lat","lon"], singletonMeta}, singleOut, []

    'metadata, missing grid dimension', false, 2, {'mat', 'test-add','standard',["lat","lon","time"],standardMeta}, [], []
    'metadata, missing singleton grid dimension', true, 1, {'mat','test-add','standard',["lat","lon","time"],standardMeta}, stanOut, []
    'metadata, missing source dimension', false, 1, {'mat','test-add','singletons',["time","lat","lon"],singletonMeta.edit('lat',[])}, [], []
    'metadata, missing singleton source (and grid) dimension', true, 1, {'nc','test-add','singletons',["run","lat","lon"], singletonMeta}, singleOut, []
    'metadata, dimension not in source', false, 1, {'mat','test-add','standard',["lat","lon","time"],standardMeta.edit('site',(1:4)')}, [], []
    'metadata, singleton dimension not in source', true, 1, {'mat','test-add','standard',["lat","lon","time"], standardMeta.edit('site',18)}, stanOut, []

    % Metadata
    'metadata has attributes', true, 1, {'mat','test-add','standard',["lat","lon","time"],standardMeta.addAttributes('Units','Kelvin')}, stanOut, []
    'metadata has dimension order', true, 1, {'mat','test-add','standard',["lat","lon","time"], standardMeta.setOrder(["time","lon","lat"])}, stanOut, []
    'metadata has wrong length', false, 1, {'mat','test-add','standard',["lat","lon","time"],standardMeta.edit('lat',(1:4)')}, [], []
    'metadata, not unique', false, 1, {'mat','test-add','standard',["lat","lon","time"],standardMeta.edit('lat',[1;2;3;1;5])}, [], []

    % Merge
    'two dimensions merged', true, 1, {'mat','test-add','singletons',["lat","lat","lon"],singletonMeta}, singleOut, {'dims',"lat,lat,lon",'size',"1,5,15",'mergedDims',"lat,lon",'mergedSize',"5,15",'mergeMap',"1,1,2"}
    '>2 dimensions merged', true, 1, {'mat','test-add','singletons',["time","time","time"], vectorMeta.edit('time',(1:75)','lat',1,'lon',1)}, {1, [1 1;1 1;1 75;1 1]}, {'dims',"time,time,time",'size',"1,5,15",'mergedDims',"time",'mergedSize',"75",'mergeMap',"1,1,1"}
    'multiple merge sets', true, 1, {'mat', 'test-add', 'merge', ["lat","lon","lat","time","lon","lon"], mergeMeta}, mergeOut, {'dims',"lat,lon,lat,time,lon,lon",'size',"2,3,2,3,2,3",'mergedDims',"lat,lon,time",'mergedSize',"4,18,3",'mergeMap',"1,2,1,3,2,2"}

    % Low dimensionality
    'empty', false, 1, {'mat','test-add','empty',"lat",gridMetadata}, [], []
    'true scalar', true, 1, {'nc', 'test-add', 'scalar', 'time', scalarMeta}, {1, [1 1;1 1;5 5;1 1]}, {'dims','time','size',"1"}
    'mat scalar', true, 1, {'mat', 'test-add', 'scalar', 'time', scalarMeta}, {1, [1 1;1 1;5 5;1 1]}, {'dims','time','size',"1"}
    'true vector', true, 1, {'nc', 'test-add', 'vector', 'time', vectorMeta}, vectorOut, {'dims','time','size',"5"}
    'mat column vector', true, 1, {'mat', 'test-add', 'vector', 'time', vectorMeta}, vectorOut, {'dims','time','size',"5"}
    };
header = "DASH";


try
    for t = 1:size(tests,1)
        meta = gridMetadata('lat',(1:50)', 'lon', (1:100)', 'time', (1:3000)', 'run', 4);
        if tests{t,3} == 2
            meta = meta.edit('run', (1:4)');
        end
        grid = gridfile.new('test.grid', meta, true);

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.add(tests{t,4}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            grid.add(tests{t,4}{:})

            assert(grid.nSource==tests{t,5}{1}, 'nSource');
            assert(isequal(grid.dimLimit, tests{t,5}{2}), 'dimLimit');

            if ~isempty(tests{t,6})
                for k = 1:2:numel(tests{t,6})-1
                    assert(isequaln(...
                        tests{t,6}{k+1}, grid.sources_.(tests{t,6}{k})), 'sources %s', tests{t,6}{k});
                end
            end

            % assert(output)
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end


%% Multiple sources
tests = {
    'multiple, mixed types', true,...
    {{'nc','test-add','standard',["lat","lon","time"], standardMeta},...
    {'mat','test-add','standard',["lat","lon","time"], standardMeta.edit('time',(21:40)')},...
    {'text','test.txt',["lat","lon"], textMeta.edit('time',41)}},...
    {3, cat(3,[2 16;6 10;1 20],[2 16;6 10;21 40],[1 4;1 7;41 41])},...
    {...
    'type',["nc";"mat";"text"],'var',["standard";"standard";""],'importOptions',cell(0,1),'importOptionSource',[],...
    'dims', ["lat,lon,time";"lat,lon,time";"lat,lon"],'size',["5,15,20";"5,15,20";"7,4"],'mergedDims',["lat,lon,time";"lat,lon,time";"lat,lon"],...
    'mergedSize', ["5,15,20";"5,15,20";"7,4"], 'mergeMap', ["1,2,3";"1,2,3";"1,2"]...
    }

    'multiple, text options', true,...
    {...
    {'nc','test-add','singletons',["time","lat","lon"], singletonMeta},...
    {'text','test.txt',["lat","lon"], textMeta.edit('time',6), 'NumHeaderLines', 3},...
    {'nc','test-add','singletons',["time","lat","lon"], singletonMeta.edit('time',7)},...
    {'text','test.txt',["lat","lon"], textMeta.edit('time',8), 'NumHeaderLines', 3},...
    {'nc','test-add','singletons',["time","lat","lon"], singletonMeta.edit('time',9)},...
    },...
    {5, cat(3,[2 16;6 10;5 5],[1 4;1 7;6 6],[2 16;6 10;7 7],[1 4;1 7;8 8],[2 16;6 10;9 9])},...
    {'importOptions',{{'NumHeaderLines',3};{'NumHeaderLines',3}}, 'importOptionSource',[2;4]}

    'metadata overlap', false, ...
    {{'nc','test-add','standard',["lat","lon","time"], standardMeta},...
    {'nc','test-add','standard',["lat","lon","time"], standardMeta}},...
    [],[]
    };

try
    for t = 1:size(tests,1)
        meta = gridMetadata('lat',(1:50)', 'lon', (1:100)', 'time', (1:3000)');
        grid = gridfile.new('test.grid', meta, true);

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                for k = 1:numel(tests{t,3})
                    grid.add(tests{t,3}{k}{:})
                end
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            for k = 1:numel(tests{t,3})
                grid.add(tests{t,3}{k}{:})
            end

            assert(grid.nSource==tests{t,4}{1}, 'nSource');
            assert(isequal(grid.dimLimit, tests{t,4}{2}), 'dimLimit');

            for k = 1:2:numel(tests{t,5})-1
                assert(isequaln(tests{t,5}{k+1}, grid.sources_.(tests{t,5}{k})), 'sources %s', tests{t,5}{k});
            end
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end





end
function[] = remove

notfile = fullfile(pwd, 'not-a-file.mat');
tests = {
    'indexed sources', true, [1 3]
    'repeated indices', true, [1 1 3]
    'named sources', true, ["test.nc";"test.mat"]
    'invalid index', false, 2.2
    'unrecognized name', false, notfile
    'repeat name', false, "test"
    };
header = "DASH:gridfile:remove";
meta = gridMetadata('lat',(1:100)', 'lon',(1:20)', 'time',(1:5)', 'run', (1:3)');

try
    for t = 1:size(tests,1)
        grid = gridfile.new('test', meta, true);
        grid.add('nc', 'test.nc', 'a', ["lat","lon","time"], meta.edit('run',1));
        grid.add('txt', 'test.txt', ["lat","lon"], meta.edit('run',2,'time',1,'lat',(1:7)','lon',(1:4)'));
        grid.add('mat', 'test.mat', 'a', ["lat","lon","time"], meta.edit('run',3));

        grid2 = gridfile.new('test2', meta, true);
        grid2.add('txt', 'test.txt', ["lat","lon"], meta.edit('run',2,'time',1,'lat',(1:7)','lon',(1:4)'));
        grid2.file = grid.file;
        grid2.sources_.gridfile = grid.file;

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.remove(tests{t,3});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            grid.remove(tests{t,3});
            assert(isequaln(grid, grid2), 'output');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = rename

% Subfolder paths
onpath = fullfile(pwd, 'on-path');
offpath = fullfile(pwd, 'off-path');
double = fullfile(pwd, 'double');
diffSize = fullfile(pwd, 'different-size');
home = pwd;
header = "DASH:gridfile:rename";

% Set up gridfile
function[grid] = setupGrid
    meta = gridMetadata('time',(1:100)','lon',(1:20)','lat',(1:5)','run',(0:3)');
    grid = gridfile.new('test', meta, true);
    grid.add('mat', 'test', 'a', ["time","lon","lat"], meta.edit('run',0));
    grid.add('mat', 'test-1', 'a', ["time","lon","lat"], meta.edit('run',1));
    grid.add('mat', 'test-2', 'a', ["time","lon","lat"], meta.edit('run',2));
    grid.add('mat', 'test-3', 'a', ["time","lon","lat"], meta.edit('run',3));
end

% Manage file paths
reset1 = onCleanup( @()rmpath(onpath) );
addpath(onpath);

% Move files
grid = setupGrid;
return1 = onCleanup( @()movefile(fullfile(onpath,  'test.mat'), home));
return2 = onCleanup( @()movefile(fullfile(onpath,'test-2.mat'), home));
movefile(fullfile(home,'test.mat'), onpath);
movefile(fullfile(home,'test-2.mat'), onpath);
paths = ["./on-path/test.mat";"./test-1.mat";"./on-path/test-2.mat";"./test-3.mat"];
try
    grid.rename;
catch
    error('move files');
end
assert(isequal(paths, grid.sources_.source));
delete(return1);
delete(return2);

% Files in same location
grid = setupGrid;
paths = ["./test.mat";"./test-1.mat";"./test-2.mat";"./test-3.mat"];
try
    grid.rename;
catch
    error('files in same location');
end
assert(isequal(paths, grid.sources_.source));

% Different type
grid = setupGrid;
return1 = onCleanup( @()movefile(fullfile(offpath,'test.mat'),home) );
return2 = onCleanup( @()movefile(fullfile(onpath,'test.mat'), double) );
movefile(fullfile(home,'test.mat'), offpath);
movefile(fullfile(double,'test.mat'), onpath);
try
    grid.rename;
    error('did not fail');
catch ME
    assert(contains(ME.identifier, header), 'invalid error');
end
delete(return1);
delete(return2);

% Different size
grid = setupGrid;
return1 = onCleanup( @()movefile(fullfile(offpath,'test.mat'),home) );
return2 = onCleanup( @()movefile(fullfile(onpath,'test.mat'), diffSize) );
movefile(fullfile(home,'test.mat'), offpath);
movefile(fullfile(diffSize,'test.mat'), onpath);
try
    grid.rename;
    error('did not fail');
catch ME
    assert(contains(ME.identifier, header), 'invalid error');
end
delete(return1);
delete(return2);

% Missing file
grid = setupGrid;
return1 = onCleanup( @()movefile(fullfile(offpath,'test.mat'),home) );
movefile(fullfile(home,'test.mat'), offpath);
try
    grid.rename;
    error('did not fail');
catch ME
    assert(contains(ME.identifier, header), 'invalid error');
end
delete(return1);

% Move absolute path
grid = setupGrid;
grid.absolutePaths(true);
return1 = onCleanup( @()movefile(fullfile(onpath,  'test.mat'), home));
return2 = onCleanup( @()movefile(fullfile(onpath,'test-2.mat'), home));
movefile(fullfile(home,'test.mat'), onpath);
movefile(fullfile(home,'test-2.mat'), onpath);
paths = [fullfile(onpath,"test.mat");fullfile(home,"test-1.mat");fullfile(onpath,"test-2.mat");fullfile(home,"test-3.mat")];
for p = 1:numel(paths)
    paths(p) = dash.file.urlSeparators(paths(p));
end
try
    grid.rename;
catch
    error('move absolute paths');
end
assert(isequal(paths, grid.sources_.source));
delete(return1);
delete(return2);

% Move indexed files
grid = setupGrid;
return1 = onCleanup( @()movefile(fullfile(onpath,  'test.mat'), home));
return2 = onCleanup( @()movefile(fullfile(onpath,'test-2.mat'), home));
movefile(fullfile(home,'test.mat'), onpath);
movefile(fullfile(home,'test-2.mat'), onpath);
paths = ["./test.mat";"./test-1.mat";"./on-path/test-2.mat";"./test-3.mat"];
try
    grid.rename(3);
catch
    error('move indexed files');
end
assert(isequal(paths, grid.sources_.source));
delete(return1);
delete(return2);

% Invalid indices
grid = setupGrid;
try
    grid.rename(17);
    error('did not fail');
catch
    assert(contains(ME.identifier, header), 'invalid error');
end

% Move named files
grid = setupGrid;
return1 = onCleanup( @()movefile(fullfile(onpath,  'test.mat'), home));
return2 = onCleanup( @()movefile(fullfile(onpath,'test-2.mat'), home));
movefile(fullfile(home,'test.mat'), onpath);
movefile(fullfile(home,'test-2.mat'), onpath);
paths = ["./on-path/test.mat";"./test-1.mat";"./on-path/test-2.mat";"./test-3.mat"];
try
    grid.rename(["test-2.mat","test.mat"]);
catch
    error('move indexed files');
end
assert(isequal(paths, grid.sources_.source));
delete(return1);
delete(return2);

% Specify new name
grid = setupGrid;
return1 = onCleanup( @()movefile(fullfile(home,  'test-A.mat'), 'test.mat'));
return2 = onCleanup( @()movefile(fullfile(home,'test-B.mat'), 'test-2.mat'));
movefile(fullfile(home,'test.mat'), 'test-A.mat');
movefile(fullfile(home,'test-2.mat'), 'test-B.mat');
paths = ["./test-A.mat";"./test-1.mat";"./test-B.mat";"./test-3.mat"];
try
    grid.rename([1 3], ["test-A.mat", "test-B.mat"]);
catch
    error('set new name');
end
assert(isequal(paths, grid.sources_.source));
delete(return1);
delete(return2);

% Set new absolute path name
grid = setupGrid;
grid.absolutePaths(true);
return1 = onCleanup( @()movefile(fullfile(home,  'test-A.mat'), 'test.mat'));
return2 = onCleanup( @()movefile(fullfile(home,'test-B.mat'), 'test-2.mat'));
movefile(fullfile(home,'test.mat'), 'test-A.mat');
movefile(fullfile(home,'test-2.mat'), 'test-B.mat');
paths = [fullfile(home,"test-A.mat");fullfile(home,"test-1.mat");fullfile(home,"test-B.mat");fullfile(home,"test-3.mat")];
for p = 1:numel(paths)
    paths(p) = dash.file.urlSeparators(paths(p));
end
try
    grid.rename([1 3], ["test-A.mat", "test-B.mat"]);
catch
    error('set new absolute path name');
end
assert(isequal(paths, grid.sources_.source));
delete(return1);
delete(return2);

% Set name, different data type
grid = setupGrid;
return1 = onCleanup( @()movefile(fullfile(offpath,'test.mat'),home) );
return2 = onCleanup( @()movefile(fullfile(onpath,'test-A.mat'), fullfile(double,'test.mat')) );
movefile(fullfile(home,'test.mat'), offpath);
movefile(fullfile(double,'test.mat'), fullfile(onpath,'test-A.mat'));
try
    grid.rename(1, "test-A.mat");
    error('did not fail');
catch ME
    assert(contains(ME.identifier, header), 'invalid error');
end
delete(return1);
delete(return2);

% Set name, different size
grid = setupGrid;
return1 = onCleanup( @()movefile(fullfile(offpath,'test.mat'),home) );
return2 = onCleanup( @()movefile(fullfile(onpath,'test-A.mat'), fullfile(diffSize,'test.mat')) );
movefile(fullfile(home,'test.mat'), offpath);
movefile(fullfile(diffSize,'test.mat'), fullfile(onpath,'test-A.mat'));
try
    grid.rename(1, "test-A.mat");
    error('did not fail');
catch ME
    assert(contains(ME.identifier, header), 'invalid error');
end
delete(return1);
delete(return2);

% Set name, missing file
grid = setupGrid;
try
    grid.rename(1, fullfile(home,'test-A.mat'));
    error('did not fail');
catch ME
    assert(contains(ME.identifier, header), 'invalid error');
end

% Set name, provide full path to file off active path
grid = setupGrid;
fullpath = fullfile(offpath, 'test-A.mat');
return1 = onCleanup( @()movefile(fullpath, fullfile(home,'test.mat')) );
movefile(fullfile(home,'test.mat'), fullpath);
paths = ["./off-path/test-A.mat";"./test-1.mat";"./test-2.mat";"./test-3.mat"];
try
    grid.rename(1, fullpath);
catch
    error('set new name');
end
assert(isequal(paths, grid.sources_.source));
delete(return1);
delete(return2);

end
function[] = absolutePaths

% File paths
path1 = dash.file.urlSeparators(fullfile(pwd, "test.nc"));
path2 = dash.file.urlSeparators(fullfile(pwd, "test.mat"));
path3 = dash.file.urlSeparators(fullfile(pwd, "test-2.mat"));
opendap = "https://psl.noaa.gov/thredds/dodsC/Datasets/cru/crutem4/var/air.mon.anom.nc";

rel1 = "./test.nc";
rel2 = "./test.mat";
rel3 = "./test-2.mat";

tests = {
    % description, should fail, data sources, initial absolute path state,
    % inputs, grid relativePath, source path/relativePath
    'switch from relative to absolute', true, 'standard', false, {true}, false, {[path1;path2;path3], [false;false;false]}
    'switch from absolute to relative', true, 'standard', true, {false}, true, {[rel1;rel2;rel3],[true;true;true]}
    'opendap to absolute', true, 'opendap', false, {true}, false, {opendap, false}
    'opendap to relative', true, 'opendap', true, {false}, true, {opendap, false}
    'indexed sources to absolute', true, 'standard', false, {true, [3 1]}, true, {[path1;rel2;path3],[false;true;false]}
    'indexed sources to relative', true, 'standard', true, {false, ["test-2.mat";"test.nc"]}, false, {[rel1;path2;rel3],[true;false;true]}
    'invalid sources', false, 'standard', false, {true, 17}, [], []
    };
header = "DASH:gridfile:absolutePaths";

try
    for t = 1:size(tests,1)
        % Build grid
        if strcmp(tests{t,3}, 'standard')
            meta = gridMetadata('time', (1:100)', 'lon', (1:20)', 'lat', (1:5)', 'run', (1:4)');
            grid = gridfile.new('test',meta,true);
            grid.add('nc', 'test', 'a', ["time","lon","lat"], meta.edit('run', 1));
            grid.add('mat', 'test', 'a', ["time","lon","lat"], meta.edit('run', 2));
            grid.add('mat', 'test-2', 'a', ["time","lon","lat"], meta.edit('run', 3));
        elseif strcmp(tests{t,3}, 'opendap')
            meta = gridMetadata('lon',(1:72)','lat',(1:36)', 'time',(1:2063)');
            grid = gridfile.new('test',meta,true);
            grid.add('nc', opendap, 'air', ["lon","lat","time"], meta);
        end

        % Set initial state
        if tests{t,4}
            grid.absolutePaths(true);
        end

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.absolutePaths(tests{t,5}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            grid.absolutePaths(tests{t,5}{:});
            assert(grid.relativePath==tests{t,6}, 'grid relative path');
            assert(isequal(grid.sources_.source, tests{t,7}{1}), 'source path');
            assert(isequal(grid.sources_.relativePath, tests{t,7}{2}), 'source relative path');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = fillValue

tests = {
    'return fill 1', true,                    {}, 5, []
    'return fill 2', true,           {'default'}, 5, []
    'return all sources', true,      {'sources'}, [5;20;30], []
    'return indexed sources', true,    {'sources', [3 1 1]}, [30;5;5], []
    
    'set default fill', true,               {10}, [], [10 10 10 10]'  
    'set source fill', true,         {17, [3;2]}, [], [5 5 17 17]'
    'invalid default fill', false,         {'5'}, [], []
    'invalid source fill', false, {[1;2], [1;2]}, [], []
    };
header = "DASH:gridfile:fillValue";
meta = gridMetadata('lat',(1:100)', 'lon',(1:20)', 'time',(1:5)', 'run', (1:3)');
m1 = meta.edit('run', 1);
m2 = meta.edit('run', 2);
m3 = meta.edit('run', 3);
args = {'nc', 'test','a',["lat","lon","time"]};

try
    for t = 1:size(tests,1)
        grid = gridfile.new('test.grid', meta, true);
        grid.fillValue(5);
        grid.add(args{:}, m1);
        grid.add(args{:}, m2);
        grid.add(args{:}, m3);
        grid.fillValue(20, 2);
        grid.fillValue(30, 3);
        
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.fillValue(tests{t,3}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            if ~isempty(tests{t,4})
                output = grid.fillValue(tests{t,3}{:});
                assert(isequal(output, tests{t,4}), 'output');
            else
                grid.fillValue(tests{t,3}{:});
                grid2 = gridfile('test.grid');
                
                fills1 = [grid.fill; grid.sources_.fill];
                fills2 = [grid2.fill; grid2.sources_.fill];
                assert(isequal(fills1, tests{t,5}), 'fills 1');
                assert(isequal(fills2, tests{t,5}), 'fills 2');
            end
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = validRange

tests = {
    'return range 1', true, {}, [-1000 1000], []
    'return range 2', true, {'default'}, [-1000 1000], []
    'return all ranges', true, {'sources'}, [-1000 1000; 5 15; 25 35], []
    'return indexed ranges', true, {'sources', [3 1 1]}, [25 35;-1000 1000;-1000 1000], []
    
    'set default range', true, {[0 100]}, [], repmat([0 100],4,1)
    'set source range', true, {[0 100], [3 2]}, [], [-1000 1000;-1000 1000;0 100;0 100]
    'invalid default range', false, {'invalid'}, [], []
    'invalid source range', false, {[0 1;0 1], [1;2]}, [], []
    };
header = "DASH:gridfile:validRange";
meta = gridMetadata('lat',(1:100)', 'lon',(1:20)', 'time',(1:5)', 'run', (1:3)');
m1 = meta.edit('run', 1);
m2 = meta.edit('run', 2);
m3 = meta.edit('run', 3);
args = {'nc', 'test','a',["lat","lon","time"]};

try
    for t = 1:size(tests,1)
        grid = gridfile.new('test.grid', meta, true);
        grid.validRange([-1000 1000]);
        grid.add(args{:}, m1);
        grid.add(args{:}, m2);
        grid.add(args{:}, m3);
        grid.validRange([5 15], 2);
        grid.validRange([25 35], 3);
        
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.validRange(tests{t,3}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            if ~isempty(tests{t,4})
                output = grid.validRange(tests{t,3}{:});
                assert(isequal(output, tests{t,4}), 'output');
            else
                grid.validRange(tests{t,3}{:});
                grid2 = gridfile('test.grid');
                
                range1 = [grid.range; grid.sources_.range];
                range2 = [grid2.range; grid2.sources_.range];
                assert(isequal(range1, tests{t,5}), 'range 1');
                assert(isequal(range2, tests{t,5}), 'range 2');
            end
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = transform

tests = {
    'return transform 1', true, {}, {"linear", [1 2]}, []
    'return transform 2', true, {'default'}, {"linear", [1 2]}, []
    'return all sources', true, {'sources'}, {["linear";"exp";"+"], [1 2;NaN NaN;5 NaN]}, []
    'return indexed sources', true, {'sources', [3 1 1]}, {["+";"linear";"linear"], [5 NaN;1 2;1 2]}, []
    'set default transform', true, {"plus", 5}, [], {repmat("plus",4,1), repmat([5 NaN],4,1)}
    'set source transform', true, {"times", 3, [3;2]}, [], {["linear";"linear";"times";"times"],[1 2;1 2;3 NaN;3 NaN]}
    
    'ln', true, {'ln'}, [], {repmat("ln",4,1), NaN(4,2)}
    'log', true, {'log'}, [], {repmat("log",4,1), NaN(4,2)}
    'log10', true, {'log10'}, [], {repmat("log10",4,1), NaN(4,2)}
    'exp', true, {'exp'}, [], {repmat("exp",4,1), NaN(4,2)}
    'power', true, {'power', 2}, [], {repmat("power",4,1), repmat([2 NaN],4,1)}
    'plus', true, {'plus', 5}, [], {repmat("plus",4,1), repmat([5 NaN],4,1)}
    'add', true, {'add', 5}, [], {repmat("add",4,1), repmat([5 NaN],4,1)}
    '+', true, {'+', 5}, [], {repmat("+",4,1), repmat([5 NaN],4,1)}
    'times', true, {'times', 3}, [], {repmat("times",4,1), repmat([3 NaN],4,1)}
    'multiply', true, {'multiply', 3}, [], {repmat("multiply",4,1), repmat([3 NaN],4,1)}
    '*', true, {'*', 3}, [], {repmat("*",4,1), repmat([3 NaN],4,1)}
    'linear', true, {'linear', [4 5]}, [], {repmat("linear",4,1), repmat([4 5],4,1)}
    'none', true, {'none'}, [], {repmat("none",4,1), NaN(4,2)}
    
    'invalid transformation', false, {'invalid'}, [], []
    '0 args, input 1', false, {'exp', 5}, [], []
    '1 arg, input 0', false, {'plus'}, [], []
    '1 arg, input 2', false, {'plus', [1 2]}, [], []
    '2 args, input 1', false, {'linear', 5}, [], []
    '2 args, input 3', false, {'linear', [1 2 3]}, [], []
    };
header = "DASH:gridfile:transform";

meta = gridMetadata('lat',(1:100)', 'lon',(1:20)', 'time',(1:5)', 'run', (1:3)');
m1 = meta.edit('run', 1);
m2 = meta.edit('run', 2);
m3 = meta.edit('run', 3);
args = {'nc', 'test','a',["lat","lon","time"]};

try
    for t = 1:size(tests,1)
        grid = gridfile.new('test.grid', meta, true);
        grid.add(args{:}, m1);
        grid.add(args{:}, m2);
        grid.add(args{:}, m3);
        grid.transform('linear', [1 2]);
        grid.transform('exp', [], 2);
        grid.transform('+', 5, 3);
        
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.transform(tests{t,3}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            if ~isempty(tests{t,4})
                [type, params] = grid.transform(tests{t,3}{:});
                assert(isequal(type, tests{t,4}{1}), 'output type');
                assert(isequaln(params, tests{t,4}{2}), 'output params');
            else
                grid.transform(tests{t,3}{:});
                grid2 = gridfile('test.grid');
                
                type1 = [grid.transform_; grid.sources_.transform];
                type2 = [grid2.transform_; grid2.sources_.transform];
                param1 = [grid.transform_params; grid.sources_.transform_params];
                param2 = [grid2.transform_params; grid2.sources_.transform_params];
                
                assert(isequaln(type1, tests{t,5}{1}), 'type 1');
                assert(isequaln(type2, tests{t,5}{1}), 'type 2');
                assert(isequaln(param1, tests{t,5}{2}), 'param 1');
                assert(isequaln(param2, tests{t,5}{2}), 'param 2');
            end
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = getLoadIndices

% Test indices
lon = [1;5;3;7;8];
lat = [4;4;7;6;6];
lev = [6;3;2];
time = (1:60)';
run = [1;4;5;8];
all = (1:100)';

tests = {
    % description, inputs, outputs
    'all dims', {1:5, {lon,lat,lev,time,run}}, {lon,lat,lev,time,run}
    'all dims, changed order', {[3 4 1 5 2], {lev,time,lon,run,lat}}, {lon,lat,lev,time,run}
    'incomplete dims, ordered', {[1 3 4], {lon, lev, time}}, {lon,all,lev,time,all}
    'incomplete dims, changed order', {[3 1 4], {lev,lon,time}}, {lon,all,lev,time,all}
    };

% Initialize grid
meta = (1:100)';
meta = gridMetadata('lon',meta,'lat',meta,'lev',meta,'time',meta,'run',meta);
grid = gridfile.new('test',meta,true);

try
    for t = 1:size(tests,1)
        output = grid.getLoadIndices(tests{t,2}{:});
        assert(isequal(output, tests{t,3}), 'output');
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = sourcesForLoad

tests = {
    'indices for all sources', {(1:20)', (1:5)', (1:200)', (1:3)'}, [1;2;3;4]
    'not all sources', {(1:20)', (1:5)', (1:200)', 1}, [1;2]
    'partial source coverage', {(1:20)', (1:3)', 101, (1:3)'}, [2;4]
    'repeated indices', {(1:20)',[1;1;3;3], 101, (1:3)'}, [2;4]
    'unordered indices', {(1:20)',[1;3;3;1], 101, (1:3)'}, [2;4]
    'indices not in any source',  {(1:20)',(1:5)',(1:100)',3}, NaN(0,1)
    };

% Initialize grid
meta = gridMetadata('lon',(1:20)','lat',(1:5)','time',(1:200)','run',(1:3)');
grid = gridfile.new('test',meta,true);
grid.add('mat','test','a',["time","lon","lat"], meta.edit('run',1,'time',(1:100)'));
grid.add('mat','test-1','a',["time","lon","lat"], meta.edit('run',1,'time',(101:200)'));
grid.add('mat','test-2','a',["time","lon","lat"], meta.edit('run',2,'time',(1:100)'));
grid.add('mat','test-3','a',["time","lon","lat"], meta.edit('run',3,'time',(101:200)'));

try
    for t = 1:size(tests,1)
        output = grid.sourcesForLoad(tests{t,2});
        assert(isequal(output, tests{t,3}), 'output');
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = buildSources

% file paths
invalid = dash.file.urlSeparators(fullfile(pwd,'invalid','test.mat'));
diffSize = dash.file.urlSeparators(fullfile(pwd,'different-size', 'test.mat'));
double = dash.file.urlSeparators(fullfile(pwd,'double','test.mat'));

% Data sources
s1 = dash.dataSource.mat('test', 'a');
s2 = dash.dataSource.mat('test-1', 'a');
s3 = dash.dataSource.mat('test-2', 'a');
s4 = dash.dataSource.mat('test-3', 'a');
props = string(properties(s1));
props(strcmp(props,'m')) = [];

tests = {
    % Description, all succeed, altered filepath, inputs, output (datasource/failed/causes)
    'build single source', true, [], 1, {s1}, false
    'build multiple sources', true, [], 1:4, {s1;s2;s3;s4}, [false;false;false;false]
    'failed build', false, invalid, 1, {[]}, true
    'different data size', false, diffSize, 1, {[]}, true
    'different data type', false, double, 1, {[]}, true
    'some failed, some succeed', false, invalid, 1:4, {[];s2;s3;s4}, [true;false;false;false]
    };

try
    for t = 1:size(tests,1)

        % Build grid
        meta = gridMetadata('lon',(1:20)','lat',(1:5)', 'time',(1:100)', 'run', (1:4)');
        grid = gridfile.new('test',meta,true);
        grid.add('mat',  'test','a',["time","lon","lat"], meta.edit('run',1));
        grid.add('mat','test-1','a',["time","lon","lat"], meta.edit('run',2));
        grid.add('mat','test-2','a',["time","lon","lat"], meta.edit('run',3));
        grid.add('mat','test-3','a',["time","lon","lat"], meta.edit('run',4));
        if ~isempty(tests{t,3})
            grid.sources_.source(1) = tests{t,3};
        end
   
        [sources, failed, causes] = grid.buildSources(tests{t,4});

        nSource = numel(tests{t,4});
        dash.assert.vectorTypeN(sources, 'cell', nSource);
        assert(isequal(failed, tests{t,6}), 'output failed report');
        dash.assert.vectorTypeN(causes, 'cell', numel(tests{t,4}));

        for s = 1:nSource
            if ~failed(s)
                dash.assert.scalarType(sources{s}, 'dash.dataSource.mat');
                for p = 1:numel(props)
                    prop = props(p);
                    assert(isequaln(sources{s}.(prop), tests{t,5}{s}.(prop)), 'output source props');
                end
                assert(isequal(causes{s}, []), 'incorrect cause');

            else
                dash.assert.scalarType(causes{s}, 'MException');
                assert(contains(causes{s}.identifier, 'DASH'), 'invalid error');
                assert(isequal(sources{s}, []), 'incorrect source');
            end
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = loadInternal

% data sources
s1 = dash.dataSource.mat('test-load.mat','a');
s2 = dash.dataSource.text('test-load-A.txt', 'NumHeaderLines', 1);
s3 = dash.dataSource.text('test-load-B.txt');
s4 = dash.dataSource.nc('test-load', 'a');
s5 = dash.dataSource.mat('test-load-merge2.mat','a');
s6 = dash.dataSource.mat('test-load-merges.mat','a');
s7 = dash.dataSource.mat('test-load-single.mat','a');
sources = {s1;s2;s3;s4;s5;s6;s7};

% Raw output arrays
Xmat = load('test-load.mat','a').a;
Xnc = ncread('test-load.nc','a');
XtextA = readmatrix('test-load-A.txt');
XtextB = readmatrix('test-load-B.txt');
Xtext = cat(3,XtextA,XtextB,NaN(size(XtextA)));

Xmerge2 = load('test-load-merge2.mat','a').a;
Xmerge2 = reshape(Xmerge2, [8 4 3]);
Xmerge = load('test-load-merges.mat','a').a;
Xmerge = permute(Xmerge, [2 5 6 1 3 4]);
Xmerge = reshape(Xmerge, [8 4 3]);

Xraw = cat(4, Xmat, Xtext, Xnc, Xmerge2, Xmerge);
Xsingle = load('test-load-single.mat','a').a;

% Data transformations
Xfill = Xraw; 
Xfill(ismember(Xfill, [62, 20062])) = NaN;

Xmatrange = Xmat;
Xmatrange(Xmatrange<62 | Xmatrange>163) = NaN;
Xncrange = Xnc;
Xncrange(Xncrange<20062 | Xncrange>20163) = NaN;
Xrange = cat(4, Xmatrange, Xtext, Xncrange);

Xtransform = cat(4, Xmat+2.2, 2+3*Xtext, log(Xnc));

% Grid metadata
meta = gridMetadata('lon', (1:8)', 'lat', [(1:4)',(11:14)'], 'time', (1:3)', 'run', (1:6)');
dims = ["lon","lat","time","run"];

% Sets of indices
matindex = {1:8,1:4,1:3,1};
textindex = {[1 2 5 6],1:4,1:2,2};
allindex = {1:8,1:4,1:2,1:3};
somemissing = {1:8,1:4,2:3,2};
allmissing = {1:8,1:4,3,2};
ordered = {[1 3 4 5 8],[1 3],2:3,1:3};
unordered = {[1 4 3 7 2 8],[3 1 4 2],[3 1],1};
unorderedSources = {[1 4 3 7 2 8],[3 1 4 2],[3 1],[3 1]};
complex = {[1 4 4 2 6 3 3 8],[3 1 1 1],[2 3 1 2],[3 1 1 2 3]};
merge2 = {[1 4 4 2 6 3 3 8],[3 1 1 1],[2 3 1 2],4};
merge = {[1 4 4 2 6 3 3 8],[3 1 1 1],[2 3 1 2],[5 4 4]};
singleindex = {1:8,1:4,1:3,6};

tests = {
    % description, inputs, adjustment type, adjustment args, output array, output metadata, output precision
    'data from single source', {1:4, matindex, 1}, [], [], Xraw(matindex{:}), meta.index(dims, matindex).setOrder(dims), []
    'data from multiple sources', {1:4, textindex, [2 3]}, [], [], Xraw(textindex{:}), meta.index(dims, textindex).setOrder(dims), []
    'data from multiple source types', {1:4, allindex, [1 2 3 4]}, [], [], Xraw(allindex{:}), meta.index(dims, allindex).setOrder(dims), []
    'some data not in a source', {1:4, somemissing, 3}, [], [], Xraw(somemissing{:}), meta.index(dims, somemissing).setOrder(dims), []
    'all data not in a source', {1:4, allmissing, []}, [], [], Xraw(allmissing{:}), meta.index(dims, allmissing).setOrder(dims), []
    
    'data subset, ordered', {1:4, ordered, [1 3 4]}, [], [], Xraw(ordered{:}), meta.index(dims, ordered).setOrder(dims), []
    'data subset, unordered', {1:4, unordered, 1}, [], [], Xraw(unordered{:}), meta.index(dims, unordered).setOrder(dims), []
    'data subset, unordered across sources', {1:4, unorderedSources, [1 4]}, [], [], Xraw(unorderedSources{:}), meta.index(dims, unorderedSources).setOrder(dims), []
    'data subset, repeated unordered elements', {1:4, complex, 1:4}, [], [], Xraw(complex{:}), meta.index(dims, complex).setOrder(dims), []

    'custom dimension order, all dims', {[3 1 4 2], complex, 1:4}, [], [], permute(Xraw(complex{:}),[3 1 4 2]), meta.index(dims,complex).setOrder(["time","lon","run","lat"]), []
    'custom dimension order, subset of dims', {[3 1], complex, 1:4}, [], [], permute(Xraw(complex{:}), [3 1 2 4]), meta.index(dims,complex).setOrder(["time","lon","lat","run"]), []
    'no dimension order', {[], complex, 1:4}, [], [], Xraw(complex{:}), meta.index(dims,complex).setOrder(dims), []

    'merge 2', {1:4, merge2, 5}, [], [], Xraw(merge2{:}), meta.index(dims,merge2).setOrder(dims), []
    'multiple merge', {1:4, merge, 5:6}, [], [], Xraw(merge{:}), meta.index(dims,merge).setOrder(dims), []
    'multiple merge, custom order', {[3 1 4 2], merge, 5:6}, [], [], permute(Xraw(merge{:}), [3 1 4 2]), meta.index(dims,merge).setOrder(["time","lon","run","lat"]), []
    'multiple merge, custom subset order', {[3 1], merge, 5:6}, [], [], permute(Xraw(merge{:}), [3 1 2 4]), meta.index(dims,merge).setOrder(["time","lon","lat","run"]), []
    'multiple merge, no order', {[], merge, 5:6}, [], [], Xraw(merge{:}), meta.index(dims,merge).setOrder(dims), []

    'fill value', {1:4, matindex, 1}, 1, {{62}}, Xfill(matindex{:}), meta.index(dims,matindex).setOrder(dims), []
    'fill value, sources', {1:4, allindex, 1:4}, 1, {{62 1},{20062 4}}, Xfill(allindex{:}), meta.index(dims,allindex).setOrder(dims), []
    'range', {1:4, matindex, 1}, 2, {{[62 163]}}, Xrange(matindex{:}), meta.index(dims,matindex).setOrder(dims), []
    'range, sources', {1:4, allindex, 1:4}, 2, {{[62 163] 1}, {[20062 20163] 4}}, Xrange(allindex{:}), meta.index(dims,allindex).setOrder(dims), []

    'none', {1:4, matindex, 1}, 3, {{'none'}}, Xraw(matindex{:}), meta.index(dims,matindex).setOrder(dims), []
    'ln', {1:4, matindex, 1}, 3, {{'ln'}}, log(Xraw(matindex{:})), meta.index(dims,matindex).setOrder(dims), []
    'log', {1:4, matindex, 1}, 3, {{'log'}}, log(Xraw(matindex{:})), meta.index(dims,matindex).setOrder(dims), []
    'log10', {1:4, matindex, 1}, 3, {{'log10'}}, log10(Xraw(matindex{:})), meta.index(dims,matindex).setOrder(dims), []
    'exp', {1:4, matindex, 1}, 3, {{'exp'}}, exp(Xraw(matindex{:})), meta.index(dims,matindex).setOrder(dims), []
    'power', {1:4, matindex, 1}, 3, {{'power',2}}, Xraw(matindex{:}).^2, meta.index(dims,matindex).setOrder(dims), []
    'plus', {1:4, matindex, 1}, 3, {{'plus', 17.5}}, Xraw(matindex{:})+17.5, meta.index(dims,matindex).setOrder(dims), []
    'add', {1:4, matindex, 1}, 3, {{'add', 17.5}}, Xraw(matindex{:})+17.5, meta.index(dims,matindex).setOrder(dims), []
    '+', {1:4, matindex, 1}, 3, {{'+', 17.5}}, Xraw(matindex{:})+17.5, meta.index(dims,matindex).setOrder(dims), []
    'times', {1:4, matindex, 1}, 3, {{'times', 6.3}}, Xraw(matindex{:})*6.3, meta.index(dims,matindex).setOrder(dims), []
    'multiply', {1:4, matindex, 1}, 3, {{'multiply', 6.3}}, Xraw(matindex{:})*6.3, meta.index(dims,matindex).setOrder(dims), []
    '*', {1:4, matindex, 1}, 3, {{'*', 6.3}}, Xraw(matindex{:})*6.3, meta.index(dims,matindex).setOrder(dims), []
    'linear', {1:4, matindex, 1}, 3, {{'linear', [1.2 8.6]}}, 1.2 + 8.6*Xraw(matindex{:}), meta.index(dims,matindex).setOrder(dims), []
    'transform, sources', {1:4, allindex, 1:4}, 3, {{'plus', 2.2, 1},{'ln',[],4},{'linear',[2 3],[2 3]}}, Xtransform(allindex{:}), meta.index(dims,allindex).setOrder(dims), []

    'auto precision single', {1:4, singleindex, 7}, [], [], Xsingle, meta.index(dims,singleindex).setOrder(dims), 'single'
    'auto precision double', {1:4, allindex, 1:4}, [], [], Xraw(allindex{:}), meta.index(dims,allindex).setOrder(dims), 'double'
    'auto missing precision double', {1:4, allmissing, []}, [], [], Xraw(allmissing{:}), meta.index(dims,allmissing).setOrder(dims), 'double'
    'specify single for double', {1:4, allindex, 1:4, 'single'}, [], [], single(Xraw(allindex{:})), meta.index(dims,allindex).setOrder(dims), 'single'
    'specify double for single', {1:4, singleindex, 7, 'double'}, [], [], double(Xsingle), meta.index(dims,singleindex).setOrder(dims), 'double'
    };

try
    for t = 1:size(tests,1)
        % Build grid
        grid = gridfile.new('test', meta, true);
        grid.add('mat', 'test-load', 'a', ["lon","lat","time"], meta.edit('run',1));
        grid.add('text', 'test-load-A.txt', ["lon","lat"], meta.edit('run',2,'time',1));
        grid.add('txt', 'test-load-B.txt', ["lon","lat"], meta.edit('run',2,'time',2));
        grid.add('nc', 'test-load', 'a', ["lon","lat","time"], meta.edit('run',3));
        grid.add('mat', 'test-load-merge2', 'a', ["lon","lat","lat","time"], meta.edit('run',4));
        grid.add('mat', 'test-load-merges', 'a', ["lat","lon","lat","time","lon","lon"], meta.edit('run',5));
        grid.add('mat', 'test-load-single', 'a', ["lon","lat","time"], meta.edit('run',6));

        % Data transformations
        if isempty(tests{t,3})
        elseif tests{t,3}==1
            for k = 1:numel(tests{t,4})
                grid.fillValue(tests{t,4}{k}{:});
            end
        elseif tests{t,3}==2
            for k = 1:numel(tests{t,4})
                grid.validRange(tests{t,4}{k}{:});
            end
        elseif tests{t,3}==3
            for k = 1:numel(tests{t,4})
                grid.transform(tests{t,4}{k}{:});
            end
        end

        % organize inpputs
        inputs = [tests{t,2}(1:3), {sources(tests{t,2}{3})}];
        if numel(tests{t,2})>3
            inputs = [inputs, tests{t,2}(4)]; %#ok<AGROW> 
        end

        % Load, test output
        [Xout, metaOut] = grid.loadInternal(inputs{:});
        assert(isequaln(Xout, tests{t,5}), 'output array');
        assert(isequaln(metaOut, tests{t,6}), 'output metadata');
        if ~isempty(tests{t,7})
            assert(isa(Xout, tests{t,7}), 'output precision');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end    

function[] = sources


name1 = string(fullfile(pwd, 'test.nc'));
name2 = string(fullfile(pwd, 'test.mat'));
name3 = string(fullfile(pwd, 'test.txt'));

name1 = dash.file.urlSeparators(name1);
name2 = dash.file.urlSeparators(name2);
name3 = dash.file.urlSeparators(name3);

tests = {
    % description, should succeed, has sources, input
    'all sources, no input', true, true, {}, [name1;name2;name3]
    'all sources, empty array', true, true, {[]}, [name1;name2;name3]
    'all sources, 0', true, true, {0}, [name1;name2;name3]
    'all sources, no sources', true, false, {}, strings(0,1)
    'index sources', true, true, {[3 1 1]}, [name3;name1;name1]
    'index sources, no sources', false, false, {1}, []
    'invalid index', false, true, {2.2}, []
    };
header = "DASH";
meta = gridMetadata('lat',(1:100)', 'lon',(1:20)', 'time',(1:5)', 'run', (1:3)');
source1 = {'nc', 'test.nc', 'a', ["lat","lon","time"], meta.edit('run', 1)};
source2 = {'mat', 'test.mat', 'a', ["lat","lon","time"], meta.edit('run',2)};
source3 = {'text', 'test.txt', ["lat","lon"], meta.edit('run',3,'time',1,'lat',(1:8)','lon',(1:4)')};

try
    for t = 1:size(tests,1)
        grid = gridfile.new('test.grid', meta, true);
        if tests{t,3}
            grid.add(source1{:});
            grid.add(source2{:});
            grid.add(source3{:});
        end

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.sources(tests{t,4}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            sources = grid.sources(tests{t,4}{:});
            assert(isequal(sources, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = info

gridfilename = dash.file.urlSeparators(fullfile(pwd, 'test.grid'));
ncfile = dash.file.urlSeparators(fullfile(pwd, 'test.nc'));
matfile = dash.file.urlSeparators(fullfile(pwd, 'test.mat'));
textfile = dash.file.urlSeparators(fullfile(pwd, 'test.txt'));
notfile = dash.file.urlSeparators(fullfile(pwd, 'not-a-file.mat'));
meta = gridMetadata('lat',(1:100)', 'lon',(1:20)', 'time',(1:5)', 'run', (1:3)');

sgrid = struct('file', gridfilename, 'dimensions',["lon","lat","time","run"],...
    'dimension_sizes', [20 100 5 3], 'metadata', meta, 'nSources', 3, ...
    'prefer_relative_paths', 1, 'fill_value', NaN, 'valid_range', [-Inf Inf], ...
    'transform', 'none', 'transform_parameters', [NaN NaN]);
nc = struct('name', 'test.nc', 'variable', 'a', 'index', 1, 'file', ncfile,...
    'data_type', 'single', 'dimensions', "lat,lon,time", 'size', [100 20 5], ...
    'fill_value', NaN, 'valid_range', [-Inf Inf], 'transform', 'none', ...
    'transform_parameters', [NaN NaN], 'uses_relative_path', 1);
text = struct('name', 'test.txt', 'variable', [], 'index', 2, 'file', textfile,...
    'data_type', 'double', 'dimensions', "lat,lon", 'size', [8 4], ...
    'fill_value', NaN, 'valid_range', [-Inf Inf], 'transform', 'none', ...
    'transform_parameters', [NaN NaN], 'uses_relative_path', 1);
mat = struct('name', 'test.mat', 'variable', 'a', 'index', 3, 'file', matfile,...
    'data_type', 'single', 'dimensions', "lat,lon,time", 'size', [100 20 5], ...
    'fill_value', NaN, 'valid_range', [-Inf Inf], 'transform', 'none', ...
    'transform_parameters', [NaN NaN], 'uses_relative_path', 1);

tests = {
    'no input', true, {}, sgrid
    '0 input', true, {0}, sgrid
    'empty array', true, {[]}, [nc;text;mat]
    '-1 input', true, {-1}, [nc;text;mat]
    'indexed sources', true, {[3 1 1]}, [mat;nc;nc]
    'named sources', true, {["test.mat";"test.nc";"test.nc"]}, [mat;nc;nc]
    'invalid index', false, {2.2}, []
    'unrecognized name', false, {notfile}, []
    'repeat name', false, {"test"}, []
    }; %#ok<STRSCALR> 
header = "DASH";
grid = gridfile.new('test', meta, true);
grid.add('nc', 'test.nc', 'a', ["lat","lon","time"], meta.edit('run',1));
grid.add('txt', 'test.txt', ["lat","lon"], meta.edit('run',2,'time',1,'lat',(1:8)','lon',(1:4)'));
grid.add('mat', 'test.mat', 'a', ["lat","lon","time"], meta.edit('run',3));

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                grid.info(tests{t,3}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            output = grid.info(tests{t,3}{:});
            assert(isequaln(output, tests{t,4}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = name
grid = gridfile.new('test', gridMetadata, true);
output = grid.name;
assert(isequal(output, "test"), 'output');
end
function[] = disp

%% empty
grid = gridfile.new('test',gridMetadata, true);
try
    grid.disp;
catch
    error('empty');
end

%% Scalar
grid = gridfile.new('test', gridMetadata('lat',(1:10)'), true);
try
    grid.disp;
catch
    error('scalar');
end

%% array
grids = [grid, grid];
try
    grids.disp;
catch
    error('array');
end

%% deleted
delete(grid);
try
    grid.disp;
catch
    error('deleted');
end

end
function[] = dispSources
    
% Scalar, No sources
meta = gridMetadata('lat',(1:100)', 'lon', (1:20)', 'time', (1:10)');
grid = gridfile.new('test.grid', meta, true);
try
    grid.dispSources;
catch
    error('no sources');
end

% Scalar, With sources
meta1 = meta.index('time', 1:5);
meta2 = meta.index('time', 6:10);
grid.add('nc','test','a', ["lat","lon","time"], meta1);
grid.add('nc','test','a', ["lat","lon","time"], meta2);

try
    grid.dispSources;
catch
    error('with sources');
end
clc;

end