function[ind] = seasonalPolygon( obj )
% Defines seasonal polygons for a UK37 PSM

% Mediterranean polygon: Nov-May
poly_m_lat=[36.25; 47.5; 47.5; 30; 30];
poly_m_lon=[-5.5; 3; 45; 45; -5.5];

% North Atlantic polygon: Aug-Oct
poly_a_lat=[48; 70; 70; 62.5; 58.2; 48];
poly_a_lon=[-55; -50; 20; 10; -4.5; -4.5];

% North Pacific polygon: Jun-Aug
poly_p_lat=[45; 70; 70; 52.5; 45];
poly_p_lon=[135; 135; 250; 232; 180];

% Convert to -180 to 180 for Med. and Atl.
lon180=obj.coord(2);
lon180(lon180>180)=lon180(lon180>180)-360;

% Convert to 0 to 360 for Pacific
lon360=obj.coord(2);
lon360(lon360<0)=360+lon360(lon360<0);     

% Get the appropriate season
if inpolygon(lon180,obj.coord(1),poly_m_lon,poly_m_lat)
    ind = [1 2 3 4 5 11 12];             
elseif inpolygon(lon180,obj.coord(1),poly_a_lon,poly_a_lat)
    ind = [8 9 10];
elseif   inpolygon(lon360,obj.coord(1),poly_p_lon,poly_p_lat)
    ind = [6 7 8];
else
    ind = (1:12)';
end

end