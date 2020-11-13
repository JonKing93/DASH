function[dist] = haversine( latlon1, latlon2 )
%% Computes the distance between lat-lon coordinates
%
% dist = haversine( latlon )
% Computes the distance between each set of latitude-longitude coordinates
%
% dist = haversine( latlon1, latlon2 )
% Computes the distance between each coordinate listed in latlon1 and each
% coordinate listed in latlon2.
%
% ----- Inputs -----
%
% latlon: A set a latitude-longitude coordinates. A numeric matrix with two
%    columns. First column is the latitude coordinates. Second column is
%    the longitude coordinate.
%
% ----- Outputs -----
%
% dist: The distance between the coordinates. 
%
%    If you provided a single input, dist is a symmetric matrix with each
%    rows and columns corresponding to the coordinates listed in latlon.
%
%    If you provided two inputs, the rows of dist correspond to latlon1 and
%    the columns correspond to latlon2.

% Default for the second set of coordinates
if ~exist('latlon2','var') || isempty(latlon2)
    latlon2 = latlon1;
end

% Radius of the Earth
R = 6378.137;

% Convert to radians
latlon1 = latlon1 * pi/180;
latlon2 = latlon2 * pi/180;

% Transpose latlon2 for singleton expansion
latlon2 = latlon2';

% Get the change in lat and lon
dLat = latlon1(:,1) - latlon2(1,:);
dLon = latlon1(:,2) - latlon2(2,:);

% Get haversine function of the central angle
a = sin(dLat/2).^2 + ( cos(latlon1(:,1)) .* cos(latlon2(1,:)) .* sin(dLon/2).^2);
c = 2 * atan2( sqrt(a), sqrt(1-a) );

% Get the distance
dist = R * c;

end