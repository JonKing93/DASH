% Initialize state vector
d = stateDesign('My NTREND Expt');

% Get the metadata and various indices
meta = metaGridfile('Tref-LME.grid');

NHindex = meta.lat > 0; % The Northern hemisphere
MayIndex = month(meta.time) == 5;  % Timesteps in the month of May
seqDex = [0 1 2 3 4];  % Sequence indices for May - Sept
meanDex = [0 1 2 3 4]; % Mean indices for May - Sept
ensMeta = {'May','June','July','Aug','Sep'};  % Metadata for sequence members.

% Edit the first variable, T
d = addVariable(d, 'Tref-LME.grid', 'T');

d = editDesign(d, 'T', 'lat', 'state', 'index', NHindex);
d = editDesign(d, 'T', 'run', 'ens');
d = editDesign(d, 'T', 'time', 'ens', 'index', MayIndex, 'seq', seqDex, 'meta', ensMeta );

% Sync the second variable, P, to T
d = addVariable(d, 'P-LME.grid', 'P');
d = syncVariables(d, 'P', 'T');

% Add and edit the third variable, the T mean
d = addVariable(d, 'Tref-LME.grid', 'T Mean');

d = editDesign(d, 'T Mean', 'lat', 'state', 'index', NHindex, 'mean', true);
d = editDesign(d, 'T Mean', 'lon', 'state', 'mean', true);
d = editDesign(d, 'T Mean', 'time', 'ens', 'index', MayIndex, 'mean', meanDex, 'meta', ensMeta );

% Review the design
dispDesign(d);