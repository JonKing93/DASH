function[] = buildDynamicEnsemble()
%% Builds a dynamic temperature ensemble from the full forcing runs of the
% CESM-LME. Takes a while to run (~1 hr on a fast workstation...)

% Build a dynamic ensemble from CESM-LME
ensDex = 2:13;    % Much of the first LME run was lost...
nEns = numel(ensDex);

% For each LME run...
for k = 1:nEns  
    run = ensDex(k);
    
    % Get the file names
    f1 = sprintf('b.e11.BLMTRC5CN.f19_g16.0%02.f.cam.h0.T.085001-184912.nc',run);
    f2 = sprintf('b.e11.BLMTRC5CN.f19_g16.0%02.f.cam.h0.T.185001-200512.nc',run);
    
    % For the first file, get lat/lon/time indexing and set up the save file
    if k == 1
        % Get the time vectors
        t1 = ncread(f1,'time');
        t2 = ncread(f2,'time');

        % Convert to datetime, concatenate into single vector
        t1 = daynoleap2datenum(t1, 0850, 'dt') - calmonths(1);
        t2 = daynoleap2datenum(t2, 1850, 'dt') - calmonths(1);

        time = [t1;t2];
        
        % Get the lon and lat values
        lon = ncread(f1,'lon');
        lat = ncread(f1,'lat');
        
        % Get dimensional sizes
        nLon = length(lon);
        nLat = length(lat);
        nTime = length(time);
        
        nT1 = length(t1);
        nState = nLon*nLat;
        
        % Preallocate the output matrix. Convert to single precision.
        Tdoff = single(  NaN(nState, nEns, nTime)  );
        
        % Save to output file. Get a write-enabled matfile object. (This
        % will eliminate the need to store multiple LME runs in active memory).
        save('Tdoff2.mat','Tdoff','time','lon','lat','-v7.3','-nocompression');
        m = matfile('Tdoff2.mat','Writable',true);
        
        % Clear large matrix from memory
        clearvars Tdoff;
        
        % Preallocate the temperature variable
        T = NaN( nLon, nLat, nTime);
        
        % Done with setup, start tracking time
        progressbar(0);
    end         
    
    % Read the temperature variable ONLY at the surface level (index 30 of dim3)
    T(:,:,1:nT1)     = squeeze(  ncread(f1,'T', [1 1 30 1], [Inf Inf 1 Inf])  );
    T(:,:,nT1+1:end) = squeeze(  ncread(f2,'T', [1 1 30 1], [Inf Inf 1 Inf])  );       
     
    % Save as state vectors
    m.Tdoff(:,k,:) = reshape(T, [nState, 1, nTime]);  
    
    % Check progress
    progressbar(k/nEns);
    fprintf(sprintf('Finished file %.f',k));
end