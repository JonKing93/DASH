function[] = build_LME_Tsurface_Full

%%%%% User Specified

% The CESM-LME runs to use
run = 2:13;

% Strings involved in the file names
nameHead = 'surface.b.e11.BLMTRC5CN.f19_g16.';
nameMid = '.cam.h0.T.';
dateStr = {'085001-184912.nc';'185001-200512.nc'};

% Pivot year for time
pivot = [850 1850];

% Metadata file name
metaFile = 'LME_Tsurface_Full_metadata.mat';

% Data file name
outFile = 'LME_Tsurface_Full.mat';

%%%%%


% Get the data for each file
for f = 1:numel(run)

    % Get a string of the current run
    currRun = num2str( run(f), '%03.f' );
    
    % Get the two file names for this run
    fName = { [nameHead, currRun, nameMid, dateStr{1}];
               [nameHead, currRun, nameMid, dateStr{2}] };
    
    % If this is the first file, get some metadata, and do some
    % preallocation.
    if f == 1
        
        % Get the time data
        time1 = ncread( fName{1}, 'time' );
        time2 = ncread( fName{2}, 'time' );
        
        % Convert to datetime array
        date1 = daynoleap2datenum( time1, pivot(1), 'dt' );
        date2 = daynoleap2datenum( time2, pivot(2), 'dt' );
        date = [date1;date2];
        
        % Get the lat, lon data
        lat = ncread(fName{1}, 'lat');
        lon = ncread(fName{1}, 'lon');
        
        % Convert the lat lon coordinates to a vector
        [lat, lon] = meshgrid(lat, lon);
        lat = lat(:);
        lon = lon(:);
        
        % Save the metadata file
        save(metaFile, 'lat','lon','date','run');
        
        % Get some sizes for T output
        nTime = numel(date);
        nState = numel(lat);
    end
    
    % Load the T data for a single run. The singleton "level" dimension
    % will act as a stand-in dimension for the "run" dimension, so it
    % remains in the dataset.
    fprintf(['Loading run %02.f',newline],run(f));
    Trun = cat(4, ncread(fName{1},'T'), ncread(fName{2},'T') );
    
    % Reshape to state vector
    fprintf(['Reshaping run %02.f',newline], run(f));
    Trun = reshape( Trun, [nState, 1, nTime] );
    
    % If this is the first file, create a matfile to hold T output. This
    % way, only a small portion of the variables stay in memory at a given
    % time.
    fprintf(['Saving run %02.f',newline], run(f));
    if f == 1
        T = [];
        save( outFile, 'T', '-v7.3' );
        m = matfile(outFile, 'Writable', true);
        m.T = Trun;
    
    % Otherwise, append to the existing matfile
    else
        m.T(:,f,:) = Trun;
    end
end

end