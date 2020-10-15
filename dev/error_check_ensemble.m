% Does an error check of the ensemble class
grid = gridfile('tref-lme.grid');
grid2 = gridfile('psl-lme.grid');
allels = [4 19 28 37, 85, 200];
els = [4 19 28 37, 85];

sv = stateVector('test');
sv = sv.add('T','tref-lme.grid');
sv = sv.add('Tmean', 'tref-lme.grid');
sv = sv.add('P','psl-lme.grid');
sv = sv.design(["T","Tmean"], ["run","time","lat"], [false, false, true], {1, allels, grid.meta.lat>0});
sv = sv.sequence("T", "time", [0 1 2], ["May";"June";"July"]);
sv = sv.design("P", "coord", true, grid2.meta.coord(:,2)>30);
sv = sv.mean('Tmean', ["lat","lon"]);

file = 'myens.ens';
[X, em, sv2] = sv.build(5, false, file, true);

P = ncread('b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PSL.085001-184912.nc','PSL');
P = P(:,grid.meta.lat>30,els(1:5));
P = reshape(P, [size(P,1)*size(P,2), size(P,3)]);

% Load
ens = ensemble(file);
[X2, em2] = ens.load;
if ~isequal(X, X2)
    error('bad');
end
fprintf('Loaded entire ensemble.\n');

if ~isequaln(em, em2)
    error('bad');
end
fprintf('Loaded ensemble metadata\n');

% Load grid
s = ens.loadGrids;
if ~isequal(s.P.data, P)
    error('bad');
end
fprintf('Loaded entire grid.\n');

if ~isequal(s.P.members.time, grid.meta.time(els))
    error('bad');
end
fprintf('Regridded ensemble members\n');

if ~isequal(s.T.gridMetadata.lat, grid.meta.lat(grid.meta.lat>0))
    error('bad');
end
fprintf('Regridded metadata\n');

% Variable names
vars = ens.variableNames;
if ~isequal(vars, em.variableNames)
    error('bad');
end
fprintf('Obtained variable names\n');

% Complete metadata
em2 = ens.loadedMetadata;
if ~isequaln(em, em2)
    error('bad');
end
fprintf('Loaded complete metadata\n');

% Load specific variable and members
useEls = [1 4 5];
useVars = "P";
ens = ens.useMembers(useEls);
ens = ens.useVariables(useVars);

[X, em2] = ens.load;
if ~isequal(X, P(:,useEls))
    error('bad');
end
fprintf('Loaded partial ensemble\n');
emq = em.extract(useVars);
emq = emq.extractMembers(useEls);
if ~isequaln(em2, emq)
    error('bad');
end
fprintf('Loaded metadata subset\n');

% Load grid
s = ens.loadGrids;
if isfield(s, 'T')
    error('bad');
end
fprintf('Loaded grid subset\n');

if ~isequal(s.P.members.time, grid.meta.time(els(useEls)))
    error('bad');
end
fprintf('Loaded gridded ensemble members subset\n');

% Loaded metadata
em3 = ens.loadedMetadata;
if ~isequaln(em2, em3)
    error('bad');
end
fprintf('Loaded metadata\n');

% Info
s = ens.info;
m = matfile(file);
if ~isequal(s.sizeInFile, size(m.X))
    error('bad');
end
fprintf('Reported file size\n');

if ~isequal(s.sizeOnLoad, size(X))
    error('bad');
end
fprintf('Reported load size\n');

if ~isequal(s.loadVariables, "P")
    error('bad');
end
fprintf('Reported loaded variables\n');

if ~isequal(s.loadMembers, useEls')
    error('bad');
end
fprintf('Reported loaded ensemble members\n');

% Add members
ens.add(1);
ens = ensemble(file);
X = ens.load;

[X2, em2, sv2] = sv.build(6, false);

if ~isequal(X, X2)
    error('bad');
end
if ~isequaln(ens.metadata, em2)
    error('bad');
end
if ~isequaln(ens.stateVector, sv2)
    error('bad');
end
fprintf('Added ensemble members\n');
