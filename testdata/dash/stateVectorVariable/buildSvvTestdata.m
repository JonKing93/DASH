function[] = buildSvvTestdata

%% Gridfiles for initializing most tests
meta = gridMetadata('lon', rand(100,3), 'lat', (1:20)', 'time', datetime(1:1000,1,1));
gridfile.new('test-llt', meta, true);

meta = meta.edit('run', ["Full";"Volcanic";"GHG"]);
gridfile.new('test-lltr', meta, true);

meta = gridMetadata(["lat","lon","time","run"], {1,1,1,1});
gridfile.new('test-lltr-different-size', meta, true);


%% Gridfiles and data for load tests

meta = gridMetadata('lon',(1:100)','lat',(1:20)','time',(1:1000)','run',(1:10000)');
grid = gridfile.new('load-lltr',meta,true);

X1 = 1:2000;
X1 = reshape(X1, 100, []);
X2 = 2001:4000;
X2 = reshape(X2, 100, []);
X3 = 4001:6000;
X3 = reshape(X3, 100, []);
save('load-data','X1','X2','X3','-v7.3');

grid.add('mat','load-data','X1',["lon","lat"], meta.edit('time',50,'run',1));
grid.add('mat','load-data','X2',["lon","lat"], meta.edit('time',200,'run',1));

grid.add('mat','load-data','X1',["lon","lat"], meta.edit('time',50,'run',2));
grid.add('mat','load-data','X2',["lon","lat"], meta.edit('time',200,'run',2));
grid.transform('plus', 100000, 3:4);

grid.add('mat','load-data','X3',["lon","lat"], meta.edit('time',50,'run',10000));

%% Data for testing sequences

X = rand(3,20,3,20,3,20);
save('load-seq','X','-v7.3');
meta = gridMetadata('lon',(1:3)', 'lat',(1:21)', 'lev', (1:3)', 'time',(1:21)','run',(1:3)','var',(1:21)');
grid = gridfile.new('load-seq', meta, true);
grid.add('mat', 'load-seq','X',["lon","lat","lev","time","run","var"],meta.index(["lat","time","var"],{1:20,1:20,1:20}));

end