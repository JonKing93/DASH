function[D] = haversine( coord, ensCoord )
%% Computes the distance between lat-lon coordinates and a set of ensemble
% coordinates.
%
% D = haversine( coord, ensCoord )
%
% ---- Inputs -----
%
% coord: A set of coordinates. First column lat, second column lon. (nCoord1 x 2)
%
% ensCoord: A second set of coordinates. First column lat, second column
%           lon. (nCoord2 x 2)

% Set the radius of the Earth
R = 6378.137;

% Convert to radians
coord = coord * pi/180;
ensCoord = ensCoord * pi/180;

% Transpose ensCoord for binary singleton expansion
ensCoord = ensCoord';

% Get the change in lat and lon
dLat = coord(:,1) - ensCoord(1,:);
dLon = coord(:,2) - ensCoord(2,:);

% Get haversine function of the central angle
a = sin(dLat/2).^2 + ( cos(coord(:,1)) .* cos(ensCoord(1,:)) .* sin(dLon/2).^2);
c = 2 * atan2( sqrt(a), sqrt(1-a) );

% Get the distance
D = R * c;

end