% This does an error check of the ensembleMetadata class
grid = gridfile('tref-lme.grid');
grid2 = gridfile('slp-cesm.grid');
els = [4 19 28 37, 85];

sv = stateVector('test');
sv = sv.add('T','tref-lme.grid');
sv = sv.add('Tmean', 'tref-lme.grid');
sv = sv.add('P','slp-cesm.grid');
sv = sv.design(["T","Tmean"], ["run","time","lat"], [false, false, true], {1, els, grid.meta.lat>0});
sv = sv.sequence("T", "time", [0 1 2], ["May";"June";"July"]);
sv = sv.design("P", "lat", true, grid2.meta.lat>30);
sv = sv.mean('Tmean', ["lat","lon"]);

P = ncread('b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PSL.085001-184912.nc','PSL');
P = P(:,grid.meta.lat>30,els(1:5));

try
    [X, em, sv2] = sv.build(5, false);
    emtest = ensembleMetadata(sv2);
catch
    error('Could not build.');
end
if ~isequaln(emtest, em)
    error('bad');
end
fprintf('Built object\n');



% Variable names
varNames = em.variableNames;
if ~isequal(varNames, sv.variableNames)
    error('bad');
end
fprintf('Acquired variable names.\n');

% Sizes
[nState, nEns] = em.sizes;
[~, info] = sv2.info(["T","Tmean","P"]);
if ~isequal( [nState, nEns], size(X))
    error('bad');
end
fprintf('Full size\n');
nState = em.sizes(["P", "T"]);
if info(3).stateSize~=nState(1)
    error('bad');
end
if info(1).stateSize~=nState(2)
    error('bad');
end
fprintf('Variable sizes\n');

% Regrid
V = em.regrid(X, "P");
if ~isequal(V, P)
    error('bad');
end
fprintf('Regridded\n');

[~, meta] = em.regrid(X, "Tmean", ["time","lon","lat"]);
if ~isequal(meta.lon, permute(grid.meta.lon, [3 2 1]))
    error('bad');
end
fprintf('Regridded metadata\n');

[V, meta] = em.regrid(X, "P", ["time","lon","lat"]);
if ~isequal(V, permute(P, [3 1 2]))
    error('bad');
end
fprintf('Regrid order\n');

% Find rows
H = em.findRows("P");
if ~isequal(H, 20737+(1:4608))
    error('bad');
end
fprintf('Found variable rows\n');

H = em.findRows("P", 'end');
if ~isequal(H, 25345)
    error('bad');
end
fprintf('Found last row\n');

H = em.findRows("P", [5 1 9]);
if ~isequal( H, 20737+[5 1 9])
    error('bad');
end
fprintf('Found rows in full vector.\n');

% Coordinates
latlon = em.coordinates;

lat1 = grid.meta.lat(grid.meta.lat>0);
lat2 = grid.meta.lat(grid.meta.lat>30);
lon = grid.meta.lon;

long1 = repmat(lon, [1, numel(lat1)]);
long2 = repmat(lon, [1, numel(lat2)]);
latg1 = repmat(lat1', [numel(lon), 1]);
latg2 = repmat(lat2', [numel(lon), 1]);

coords = [repmat([latg1(:), long1(:)], [3 1]); NaN NaN; latg2(:), long2(:)];
if ~isequaln(latlon, coords)
    error('bad');
end
fprintf('Collected coordinates\n');

% Dimension
time = em.dimension('time', true);
correct = repmat(["May", "June", "July"], [numel(long1), 1]);
correct = correct(:);
if ~isequal(time.T, correct)
    error('bad');
end
fprintf('Collected dimension\n');
fprintf('Returned structure\n');

if ~isequaln(time.P, NaN(numel(long2),1))
    error('bad');
end
fprintf('Collected empty dimension\n');

long1 = repmat(long1(:), [3 1]);
latg1 = repmat(latg1(:), [3 1]);

time = em.dimension('time');
if any(~strcmp(time(numel(long1)+1:end), ""))
    error('bad');
end
fprintf('Infilled strings\n');

coord = em.dimension('coord');
if ~isequaln( coord(1:numel(long1)+1,:), NaN(numel(long1)+1,2))
    error('bad');
end
fprintf('Infilled columns\n');

% Variable
T = em.variable('T');
if ~isequal(T.lon, long1)
    error('bad');
end
if ~isequal(T.lat, latg1)
    error('bad');
end
if ~isequal(T.time, grid.meta.time(els))
    error('bad');
end
if ~isequal(T.run, 2*ones(numel(els),1))
    error('bad')
end
fprintf('Variable metadata\n');

lon = em.variable('T', "lon");
if ~isequal(lon, long1)
    error('bad');
end
time = em.variable('T', 'time');
if ~isequal(time, grid.meta.time(els))
    error('bad')
end
fprintf('Extracted array\n');

time = em.variable('T','time',true);
if ~isequal(time, correct)
    error('bad');
end
lon = em.variable('T','lon',false);
if ~isempty(lon)
    error('bad');
end
fprintf('Changed direction\n');

index = [1 5 3 5]';
lon = em.variable('T','lon',[], {index});
if ~isequal(lon, long1(index))
    error('bad')
end
fprintf('Extracted metadata at indices\n');

% Adjust variables
svq = sv.remove('T');
[~, emq] = svq.build(5, false);
em2 = em.remove('T');
if ~isequaln(em2, emq)
    error('bad');
end
fprintf('Removed variable\n');

em2 = em.extract(["Tmean","P"]);
if ~isequaln(em2, emq)
    error('bad');
end
fprintf('Extracted variables\n');

em1 = em.extract('T');
em3 = em1.append(em2);
if ~isequaln(em, em3)
    error('bad');
end
fprintf('Appended variables\n');


% Adjust ensemble members
newels = els([1 4 5]);
svq = sv.design(["T","Tmean"], ["run","time","lat"], [false, false, true], {1, newels, grid.meta.lat>0});
[~, emq] = svq.build(3, false);
em2 = em.removeMembers([2 3]);
if ~isequaln(em2, emq)
    error('bad');
end
fprintf('Removed ensemble members\n');

em2 = em.extractMembers([1 4 5]);
if ~isequaln(em2, emq)
    error('bad');
end
fprintf('Extracted ensemble members\n');

em1 = em.extractMembers([1 2]);
em2 = em.extractMembers([3 4 5]);
em3 = em1.appendMembers(em2);
if ~isequaln(em, em3)
    error('bad');
end
fprintf('Appended ensemble members\n');


