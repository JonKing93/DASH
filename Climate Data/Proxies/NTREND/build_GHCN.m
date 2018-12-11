function[ghcn] = build_GHCN( ghcnFile, outFile, metaMatfile )
%% Converts a GHCN-monthly file to .mat
%
% build_GHCN( ghcnFile, outFile, metaMatfile )
% Saves the GHCN data as a .mat file. Adds time information to the GHCN
% metadata.
%
% build_GHCN( ghcnFile, outFile )
% Does not record time information to the metadata file.
%
% ghcn = build_GHCN( ghcnFile )
% Returns the ghcn data as an array.
%
% ----- Inputs -----
%
% ghcnFile: Filename of a GHCN-monthly data file. In the GHCN archives,
%      this is typically something like 'ghcnm.tavg.v3.3.0.20181210.qca.dat'
%
% outFile: Filename of the output file. (E.g. 'ghcnData.mat')
%
% metaMatfile: Filename of the .mat file storing GHCN metadata. Please see
%      the "build_GHCN_metadata.m" function to generate.
%
% ----- Outputs ----
%
% ghcn: An array of GHCN data.

% Read the ghcn data
gdata = fileread( ghcnFile );

% Get the index of the first newline to get the number of elements per line
nElts = find( gdata == newline, 1);

% Reshape into array
nLine = numel(gdata) / nElts;
gdata = reshape(gdata, [nElts, nLine]);
gdata = gdata';

% Get the first and last years with obs in the dataset
year = str2num( gdata(:,12:15) );
yearLim = [min(year), max(year)];

% Get the number of stations and indices of each station
station = str2num( gdata(:,1:11) );
[C, ~, stationDex] = unique(station);

nStation = numel( unique(C) );

% Preallocate the data matrix and matrix of monthly values
nTime = (yearLim(2) - yearLim(1) + 1) * 12;
ghcn = NaN(nTime, nStation);
monthVal = NaN( nLine, 12);

% Get the start, width, and distance to next value
v0 = 20;   % Initial index
vw = 4;    % Width of value field
vd = 8;    % Distance until next value field

% For each month
for m = 1:12
    
    % Get the starting index of the values for the month
    vs = v0 + (m-1)*vd;    
    
    % Get the values
    monthVal(:,m) = str2num( gdata(:, vs:vs+vw) );
end
    
% Get the index of each year by shifting relative to the first year
yearDex = year - yearLim(1);

% For each line...
for n = 1:nLine
    
    % Fill in the values on the correct station and year
    ghcn( yearDex(n)*12 + (1:12), stationDex(n) ) = monthVal(n,:);
end

% Convert fill value to NaN
ghcn( ghcn == -9999 ) = NaN;

% Convert to Kelvin
ghcn = (ghcn ./ 100) + 273.15;

% Save if no output
if nargout == 0
    save( outFile, 'ghcn' );
    ghcn = [];
end

% Get time metadata if desired
if exist( 'metaMatfile', 'var')
    
    % Get the years
    year = yearLim(1):yearLim(2);
    nYear = numel(year);
    
    year = repmat(year, [12,1]);
    year = year(:);
    
    % Get the months
    month = repmat( (1:12)', nYear, 1);
    
    % Get a datetime
    date = datetime( year, month, 15);
    
    % Add to the matfile
    m = matfile( metaMatfile, 'Writable', true );
    m.date = date;
end
    
end