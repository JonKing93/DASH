function[] = tests

% Move to test folder
here = mfilename('fullpath');
folders = strsplit(here, filesep);
dash = folders(1:end-2);
testpath = fullfile(dash{:}, 'testdata', 'gridfile');

home = pwd;
gohome = onCleanup( @()cd(home) );
cd(testpath);

% Run the tests
new;
constructor;

metadata;
edit;
expand;
addDimension;

addAttributes;
removeAttributes;
editAttributes;



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
function[] = edit

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

