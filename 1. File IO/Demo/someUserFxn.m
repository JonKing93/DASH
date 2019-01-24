function[P, lat, lon, time, run] = someUserFxn( k )
%% This represents operations done by the user for the gridfile demo

% Metadata
lat = linspace(-90, 90, 15);
lon = linspace(0, 360, 22);

year = repmat(1:12,12,1);
month = repmat( (1:12)', 12, 1 );
time = datetime( year(:), month, 15);


% (pre-industrial), run 1
if k==1
    time = time(1:96);
    P = rand( numel(lon), numel(lat), numel(time));
    run = 1;
    
% Post-industrial, run 1
elseif k==2
    time = time(97:144);
    P = rand(numel(lon), numel(lat), numel(time));
    run = 1;
    
elseif k==3 
    P = rand( numel(lon), numel(lat), numel(time) );
    run = 4;
    
elseif k==4
    P = rand( numel(lat), numel(lon), numel(time) );
    run = 2;
    
elseif k==5
    lat = linspace(-90,90,5);
    lon = linspace(0, 360, 10);
    P = rand( numel(time), 1, numel(lat), numel(lon) );
    run = 3;
    
elseif k==6
    P = rand( numel(time), 1, numel(lat), numel(lon) );
    run = 3;
    
elseif k == 7
    P = rand( 4, 3, numel(lon) );
    run = [];
end
    
end
