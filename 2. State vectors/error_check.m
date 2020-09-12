% Error checker for state vector

grid = gridfile('tref-lme.grid');
meta = grid.metadata;
june = month(meta.time)==6;
run5 = meta.run==5;
nh = meta.lat>0;

raw = 'b.e11.BLMTRC5CN.f19_g16.005.cam.h0.TREFHT.085001-184912.nc';
T = double(ncread(raw, 'TREFHT'));
lat = ncread(raw, 'lat');
lon = ncread(raw, 'lon');
time = datetime(850,1,15):calmonths(1):datetime(1849,12,15);
[nLon, nLat, nTime] = size(T);


% June from run 5
sv = stateVector('test');
sv = sv.add('T', 'tref-lme.grid');
sv = sv.design('T', ["time","run","lat"], [false, false, true], {june, run5, nh});
X = sv.buildEnsemble(15, false);

A = T(:,lat>0, 6:12:174);
A = reshape(A, size(X));

if ~isequal(A, X)
    error('bad');
end
fprintf('Reference/state indices correct\n');

% Coupling
sv = sv.add('T2', 'tref-lme.grid');
sv = sv.copy('T', 'T2');
X = sv.buildEnsemble(15);

half = size(A,1);
if ~isequal( X(1:half,:), X(half+1:end,:))
    error('bad');
end
fprintf('Coupled variables\n');

% Uncoupling
sv = sv.uncouple(["T","T2"]);
X = sv.buildEnsemble(15);
if isequal(X(1:half,:), X(half+1:end,:))
    error('bad');
end
fprintf('Uncoupled variables.\n');

% JJA sequence
sv = stateVector('test');
sv = sv.add('T', 'tref-lme.grid');
sv = sv.design('T', ["time","run","lat"], [false, false, true], {june, run5, nh});
sv = sv.sequence('T','time', [0 1 2], ["June";"July";"August"]);
X = sv.buildEnsemble(15, false);

A = T(:, lat>0, ismember(month(time), [6 7 8]));
A = A(:,:,1:15*3);
A = reshape(A, size(X));

if ~isequal(A, X)
    error('bad');
end
fprintf('Built sequence\n');

% Prevent overlap
sv = stateVector('test');
sv = sv.add('T', 'tref-lme.grid');
sv = sv.design('T', ["time","run","lat"], [false, false, true], {june, run5, nh});
sv = sv.sequence('T', 'time', [0 12 24], [1;2;3]);
X = sv.buildEnsemble(15, false);

A = T(:,lat>0, 6:12:534);
A = reshape(A, size(X));
if ~isequal(round(A,13), round(X,13))
    error('bad');
end
fprintf('Prevented overlap\n');

% Allow overlap
sv = stateVector('test');
sv = sv.add('T', 'tref-lme.grid');
sv = sv.design('T', ["time","run","lat"], [false, false, true], {june, run5, nh});
sv = sv.sequence('T', 'time', [0 12 24], [1;2;3]);
sv = sv.allowOverlap('T', true);
X = sv.buildEnsemble(15, false);

A = NaN(size(X));
for k = 1:15
    start = 6+12*(k-1);
    aa = T(:,lat>0, start:12:start+24);
    A(:,k) = aa(:);
end

if ~isequal(A, X)
    error('bad')
end
fprintf('Allowed overlap\n');

% JJA Mean
sv = stateVector('test');
sv = sv.add('T', 'tref-lme.grid');
sv = sv.design('T', ["time","run","lat"], [false, false, true], {june, run5, nh});
sv = sv.mean('T',["lat","lon","time"], {[],[],[0 1 2]});
X = sv.buildEnsemble(15, false);

A = T(:, lat>0, ismember(month(time), [6 7 8]));
A = A(:,:,1:15*3);
A = reshape(A, 144, 96/2, 3, 15);
A = squeeze(mean(A, [1 2 3]))';
if isequal(round(A,13), round(X,13))
    error('bad');
end
fprintf('Took mean.\n');

% Combine sequence and mean
sv = stateVector('test');
sv = sv.add('T', 'tref-lme.grid');
sv = sv.design('T', ["time","run","lat"], [false, false, true], {june, run5, nh});
sv = sv.sequence('T',"time", [0 12 24], ["June","July","August"]);
sv = sv.mean('T',["lat","lon","time"], {[],[],[0 1 2]});
X = sv.buildEnsemble(15,false);

A = T(:,lat>0, ismember(month(time), [6 7 8]));
A = A(:,:,1:45*3);
A = reshape(A, [144, 96/2, 9, 15]);
A = mean(A, [1 2]);
A = cat(3, mean(A(:,:,1:3,:),3), mean(A(:,:,4:6,:),3), mean(A(:,:,7:9,:),3) );
A = reshape(A, size(X));

if ~isequal(round(A,12), round(X,12))
    error('bad');
end
fprintf('Used both means and sequences.\n');

% Take a weighted mean
sv = stateVector('test');
sv = sv.add('T', 'tref-lme.grid');
sv = sv.design('T', ["time","run","lat"], [false, false, true], {june, run5, nh});
sv = sv.weightedMean('T', ["lat", "lon"], {cosd(lat(lat>0)), []});
X = sv.buildEnsemble(15);

A = T(:,lat>0, 6:12:174);
w = cosd(lat(lat>0))';
A = sum(A.*w,2) ./ sum(w);
A = mean(A,1);
A = squeeze(A)';

if isequal(round(A,12), round(X,12))
    error('bad');
end
fprintf('Took weighted mean using cell\n');

% Weighted mean with array
w = repmat(w, [144, 1]);
sv = sv.weightedMean('T', ["lon","lat"], w);
X = sv.buildEnsemble(15);

if isequal(round(A,12), round(X,12))
    error('bad');
end
fprintf('Took weighted mean using array\n');

% Summary methods
sv.variableNames
sv.dimensions
sv.info('T')
fprintf('Displayed info\n');

% Autocouple
sv = sv.autoCouple('T',false);
sv = sv.add('T', 'tref-lme.grid');
if ~isequal(sv.coupled, [true false;false true])
    error('bad');
end
fprintf('Disabled autocouple\n');

% Specify metadata
yearmeta = (850:2005)';
sv = sv.specifyMetadata('T','time', yearmeta);
newmeta = sv.variables(1).dimMetadata([], 'time');

if ~isequal(newmeta, yearmeta)
    error('bad');
end
fprintf('Specified metadata\n');

% Convert metadata
sv = sv.resetMetadata;
sv = sv.convertMetadata('T','time', @year);
newmeta = sv.variables(1).dimMetadata(grid, 'time');

if ~isequal(newmeta, yearmeta)
    error('bad');
end
fprintf('Converted metadata\n');

% Console
sv = sv.notifyConsole(false);
if sv.verbose
    error('bad')
end
fprintf('Disabled console\n');

% Rename
sv = sv.rename('test2');
if ~strcmp(sv.name, 'test2')
    error('bad');
end
fprintf('Renamed\n');

% Rename variable
sv = sv.renameVariables('T', 'X');
vars = sv.variableNames;
if ~strcmp(vars(1), 'X')
    error('bad');
end
fprintf('Renamed variable\n');

% Append
sv = stateVector();
sv2 = stateVector();
sv = sv.add('T','tref-lme.grid');
sv2 = sv2.add('T2','tref-lme.grid');
sv3 = sv.append(sv2);
vars = sv3.variableNames;
if ~isequal(vars, ["T";"T2"])
    error('bad');
end
fprintf('Appended vectors.\n');

% Remove
sv = sv3.remove('T2');
vars= sv.variableNames;
if ~isequal(vars, "T")
    error('bad');
end
fprintf('Removed variable\n');

% Extract
sv = sv3.extract('T2');
vars = sv.variableNames;
if ~isequal(vars, "T2")
    error('bad');
end
fprintf('Extracted variable\n');