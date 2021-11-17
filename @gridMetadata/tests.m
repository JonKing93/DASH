function[] = tests
%% gridMetadata.tests  Unit tests for the gridMetadata class
% ----------
%   gridMetadata.tests
%   Runs the tests. If successful, exits silently. Otherwise, throws error
%   at the first failed tests.
% ----------
%
% <a href="matlab:dash.doc('gridMetadata.tests')">Documentation Page</a>

dimensions;
assertField;

constructor;
edit;
index;
setOrder;

addAttributes;
removeAttributes;
editAttributes;

defined;

disp;
dispAttributes;

assertUnique;
assertScalar;

fprintf('gridMetadata passed the tests\n');

end

function[] = dimensions
dimensions = ["lon";"lat";"lev";"site";"time";"run";"var"];
attributes = "attributes";
[dims, atts] = gridMetadata.dimensions;
assert(isequal(dimensions, dims) && isequal(atts, attributes), 'dimensions');
end
function[] = assertField

tests = {
    % description, should succeed, field, input name
    'numeric', true, [1 2;3 4], []
    'logical', true, [true, false;false, true], []
    'char', true, ['abc';'123'], []
    'string', true, ["a","b";"c","d"], []
    'datetime', true, [datetime(1,1,1);datetime(2,2,2)], []
    'cellstring', true, {'a','b';'c','d'}, []
    'repeated rows', true, [1;2;1;2], []
    'unsupported data type', false, struct('a',1), []
    'not a matrix', false, ones(3,3,3), []
    'NaN', false, [1;NaN;2], []
    'NaT', false, [datetime(1,1,1); NaT], []
    'custom error', false, struct, 'my dimension'
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            gridMetadata.assertField(tests{t,3}, tests{t,4}, testHeader);
        catch ME
        end
        assert(contains(ME.identifier, testHeader));
        
    else
        requiredOutput = tests{t,3};
        if iscellstr(requiredOutput)
            requiredOutput = string(requiredOutput);
        end
        output = gridMetadata.assertField(tests{t,3}, tests{t,4}, testHeader);
        assert(isequal(output, requiredOutput), tests{t,1});
    end
end

end
function[] = constructor

tests = {
    % description, inputs
    'empty', {}
    'some dimensions', {'lat', 1, 'lon', 2}
    'dimensions and attributes', {'lev', 1, 'run', 5, 'attributes', struct('a',1)}
    'only attributes', {'attributes', struct('a',1)}
    };

for t = 1:size(tests,1)
    try
        meta = gridMetadata(tests{t,2}{:});
    catch
        error( tests{t,1} );
    end
end

end
function[] = edit

s = struct('lat',5,'lon', [1 2;3 4], 'run', ["full forcing","1";"volcanic","13"], 'time', datetime(1,1,1), 'attributes',  struct('a',1,'b',struct('c',2)) );
initialOrder = ["time","lat","lon"];

tests = {
    % description, should succeed, inputs, check values
    'dimensions', true, {'lat',s.lat,'lon',s.lon,'run',s.run,'time',s.time}, ["lat","lon","run","time"]
    'empty metadata', true, {'lat', []}, "lat0"
    'attributes', true, {'attributes', s.attributes}, "attributes"
    'invalid dimension name', false, {'blarn', 5}, []
    'repeated dimension name', false, {'lat',5,"lat",5}, []
    'invalid dimension metadata', false, {'lat', s.attributes}, []
    'invalid attributes', false, {'attributes', 5}, []
    'maintain order', true, {'time',5}, "initialOrder"
    'new dimension reset order', true, {'lev',2}, "unordered"
    'remove dimension reset order', true, {'lat', []}, "unordered"
    };

for t = 1:size(tests,1)
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            meta.edit(tests{t,3}{:});
        catch ME
        end
        assert(contains(ME.identifier, "DASH:gridMetadata"));
        
    else
        meta = gridMetadata('lat', s.lat, 'lon',s.lon, 'time', s.time);
        meta = meta.setOrder(initialOrder);
        meta = meta.edit(tests{t,3}{:});
        
        checks = tests{t,4};
        if strcmp(checks, 'unordered')
            assert(isequal(strings(1,0), meta.order), tests{t,1});
        elseif strcmp(checks, 'initialOrder')
            assert(isequal(initialOrder, meta.order), tests{t,1});
        elseif strcmp(checks, 'lat0')
            assert(isequal([], meta.lat), tests{t,1});
        else
            for k = 1:numel(checks)
                dim = checks(k);
                assert(isequal(meta.(dim), s.(dim)), tests{t,1});
            end
        end
    end
end

end
function[] = index

lat = (-90:90)';
lon = (0:359)';
run = (1:13)';

nh = find(lat>0);
full = run<6;

tests = {
    % description, should succeed, inputs, compare to values
    'syntax 1', true, {["lat","run"], {nh, full}}, ["lat","run"], {lat(nh), run(full)}
    'syntax 2', true, {'lat', nh, 'run', full}, ["lat","run"], {lat(nh), run(full)}
    'mixed syntaxes', false, {["lat","run"], {nh, full}, 'lon', 1}, [], []
    'empty indices', true, {'lat', []}, "lat", {NaN(0,1)}
    'invalid dimension', false, {'blarn', 5}, [], []
    'repeated dimension', false, {'lat', nh, 'lat', nh}, [], []
    'invalid index collection', false, {'lat', struct('a',1)}, [], []
    'invalid indices', false, {'lat', 300}, [], []
    };

for t = 1:size(tests,1)
    meta = gridMetadata('lat', lat, 'lon', lon, 'run', run);
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            meta.index(tests{t,3}{:});
        catch ME
        end
        assert(contains(ME.identifier, 'DASH:gridMetadata'), tests{t,1});
        
    else
        meta = meta.index(tests{t,3}{:});
        checks = tests{t,4};
        for k = 1:numel(checks)
            dim = checks(k);
            match = tests{t,5}{k};
            assert(isequal(meta.(dim), match), tests{t,1});
        end
    end
end

end
function[] = setOrder

tests = {
    % description, should succeed, inputs, require output
    'syntax 1', true, {["time","lat","lon"]}, ["time","lat","lon"]
    'syntax 2', true, {'time','lat','lon'}, ["time","lat","lon"]
    'delete order', true, {0}, strings(1,0)
    'mixed syntax', false, {["time","lat"], 'lon'}, []
    'unrecognized dimension', false, {'blarn','time','lat','lon'}, []
    'repeated dimension', false, {'time','time','lat','lon'}, []
    'undefined dimension', false, {'time','lev','lat','lon'}, []
    'missing defined dimension', false, {'time', 'lon'}, []
    };

for t = 1:size(tests,1)
    meta = gridMetadata('lon',1,'lat',1,'time',1);
    shouldFail = ~tests{t,2};
    
    if shouldFail
        try
            meta.setOrder(tests{t,3}{:});
        catch ME
        end
        assert(contains(ME.identifier, 'DASH:gridMetadata'), tests{t,1});
       
    else
        meta = meta.setOrder(tests{t,3}{:});
        assert(isequal(meta.order, tests{t,4}), tests{t,1});
    end
end

end
function[] = addAttributes

s = struct('a',1,'b',2,'c',3);

tests = {
    % description, should succeed, inputs
    'add attributes', true, {'b',2,'c',3}
    'existing field',false, {'a',5}
    'invalid field name',false, {'?asdf', 5}
    'invalid name,value pairs',false, {4,5,6}
    };

for t = 1:size(tests,1)
    meta = gridMetadata('attributes', struct('a',1));
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            meta = meta.addAttributes(tests{t,3}{:});
        catch ME
        end
        assert(contains(ME.identifier, 'DASH:gridMetadata:addAttributes'));
        
    else
        meta = meta.addAttributes(tests{t,3}{:});
        assert(isequal(s, meta.attributes), tests{t,1});
    end
end

end
function[] = removeAttributes

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

for t = 1:size(tests,1)
    meta = gridMetadata('attributes',tests{t,3});
    shouldFail = ~tests{t,2};
    
    if shouldFail
        try
            meta.removeAttributes(tests{t,4}{:});
        catch ME
        end
        assert(contains(ME.identifier, 'DASH:gridMetadata:removeAttributes'), tests{t,1});
        
    else
        meta = meta.removeAttributes(tests{t,4}{:});
        assert(isequal(meta.attributes, tests{t,5}), tests{t,1});
    end
end

end
function[] = editAttributes

atts = struct('a',1,'b',2,'c',3);
edited = struct('a',1,'b',5,'c',6);

tests = {
    % description, should succeed, inputs
    'edit', true, {'c',6,'b',5}
    'not an attribute', false, {'d',5}
    'repeat dimension', false, {'b',5,'b',5}
    };

for t = 1:size(tests,1)
    meta = gridMetadata('attributes',atts);
    shouldFail = ~tests{t,2};
    
    if shouldFail
        try
            meta.editAttributes(tests{t,3}{:});
        catch ME
        end
        assert(contains(ME.identifier, 'DASH:gridMetadata:editAttributes'), tests{t,1});
        
    else
        meta = meta.editAttributes(tests{t,3}{:});
        assert(isequal(edited, meta.attributes));
    end
end

end
function[] = defined

start = {'lon', 1, 'lat', 1, 'time', 1};

tests = {
    % description, inputs, match outputs
    'list defined dimensions', {}, ["lon";"lat";"time"]
    'remove dimension', {'lat', []}, ["lon";"time"]
    'add new defined', {'lev', 1}, ["lon";"lat";"lev";"time"]
    };

for t = 1:size(tests,1)
    meta = gridMetadata(start{:});
    meta = meta.edit(tests{t,2}{:});
    defined = meta.defined;
    assert(isequal(defined, tests{t,3}), tests{t,1});
end

end
function[] = disp

tests = {
    % description, callinb object
    'empty', gridMetadata
    'scalar', gridMetadata('lat',1)
    'array', [gridMetadata('lat',1), gridMetadata('lon',2)]
    };

for t = 1:size(tests,1)
    try
        tests{t,2}.disp;
        clc;
    catch
        error(tests{t,1});
    end
end

end
function[] = dispAttributes

atts = struct('a',1,'b',2);

tests = {
    % description, calling object
    'empty', gridMetadata
    'attributes', gridMetadata('attributes', atts)
    'no attributes', gridMetadata('lat',1)
    };

for t = 1:size(tests,1)%%
    try
        tests{t,2}.dispAttributes;
        clc;
    catch
        error(tests{t,1});
    end
end

end
function[] = assertUnique

tests = {
    % description, shouldSucceed, calling object
    'empty', true, gridMetadata
    'unique', true, gridMetadata('lat', [1 2;3 4], 'lon', [50 60;70 80;90 100]);
    'repeat rows in different dimensions', true, gridMetadata('lat', [1 2;3 4], 'lon', [1 2;3 4])
    'not unique', false, gridMetadata('lat', [1 2;3 4;1 2])
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    try
        tests{t,3}.assertUnique(testHeader);
        assert(tests{t,2}, tests{t,1});
    catch ME
        assert(~tests{t,2} && contains(ME.identifier, testHeader), tests{t,1});
    end
end

end
function[] = assertScalar

tests = {
    % description, should pass, calling object
    'empty', true, gridMetadata
    'scalar', true, gridMetadata('lat',1)
    'array', false, [gridMetadata('lat',1), gridMetadata('lon',2)]
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    try
        tests{t,3}.assertScalar(testHeader);
        assert(tests{t,2}, tests{t,1});
    catch ME
        assert(~tests{t,2} && contains(ME.identifier, testHeader), tests{t,1});
    end
end

end

