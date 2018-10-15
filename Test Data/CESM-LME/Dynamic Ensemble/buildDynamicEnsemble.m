% Build a dynamic ensemble from CESM-LME
nEns = 13;
for k = 1:nEns
    k
    
    % Get the file name
    f1 = sprintf('b.e11.BLMTRC5CN.f19_g16.0%02.f.cam.h0.T.085001-184912.nc',k);
    f2 = sprintf('b.e11.BLMTRC5CN.f19_g16.0%02.f.cam.h0.T.185001-200512.nc',k);
    
    % Read the temperature variables
    temp1 = ncread(f1,'T');
    temp2 = ncread(f2,'T');
    
    % Restrict to surface level.
    temp1 = squeeze( temp1(:,:,end,:) );
    temp2 = squeeze( temp2(:,:,end,:) );
    
    % Concatenate in time
    T = cat(3, temp1, temp2);
    
     % For the first file
    if k == 1
        % Get the time vectors
        t1 = ncread(f1,'time');
        t2 = ncread(f2,'time');

        % Convert to datetime, concatenate into single vector
        t1 = datetime(0651,01,01+t1);
        t2 = datetime(0651,01,01+t2);

        time = [t1;t2];
        
        % Get the lon and lat values
        lon = ncread(f1,'lon');
        lat = ncread(f1,'lat');
        
        % Preallocate the output matrix
        sT = size(T);
        Tdoff = NaN( sT(1)*sT(2), nEns, sT(3) );
    end 
     
    % Convert to state vectors
    Tdoff(:,k,:) = reshape(T, [sT(1)*sT(2), sT(3)]);  
end

% Save
save('Tdoff.mat', 'Tdoff', 'time', 'lon', 'lat');