% Build example DA stack
f1 = 'b.e11.B1850C5CN.f19_g16.0850cntl.001.cam.h0.T.085001-184912.nc';
f2 = 'b.e11.B1850C5CN.f19_g16.0850cntl.001.cam.h0.T.185001-200512.nc';

% Get the time vectors
t1 = ncread(f1,'time');
t2 = ncread(f2,'time');

% Convert to datetime, concatenate into single vector
t1 = datetime(0651,01,01+t1);
t2 = datetime(0651,01,01+t2);

time = [t1;t2];

% Read the temperature variables
temp1 = ncread(f1,'T');
temp2 = ncread(f2,'T');

% Restrict to surface level, concatenate into single vector
temp1 = squeeze( temp1(:,:,end,:) );
temp2 = squeeze( temp2(:,:,end,:) );

T = cat(3, temp1, temp2);

% Get the lon and lat values
lon = ncread(f1,'lon');
lat = ncread(f1,'lat');

% Save
save('sampleTStack.mat','T','time','lon','lat');