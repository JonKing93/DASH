% Test the ensemble builder

meta = metaGridfile('Ttest.mat');
nh = meta.lat>0;
june = month(meta.time)==6;
jan = month(meta.time)==1;

d = stateDesign('new');
d = addVariable(d, 'Ttest.mat', 'T JJA');
d = addVariable(d, 'Ttest.mat', 'T seq');

d = editDesign(d, 'T JJA','run','ens');
d = editDesign( d, 'T JJA', 'lat', 'state', nh);
d = editDesign( d, 'T JJA', 'time', 'ens', june, 'mean', [0 1 2],'meta','JJA mean');

d = editDesign(d, 'T seq', 'time', 'ens', jan, 'seq', [0 1 2], 'meta','JJA');

d = coupleVariables(d, 'T seq', 'T JJA', 'noseq', 'nomean' );

% Build the thing
[M, ensMeta] = buildEnsemble( d, 300 );

