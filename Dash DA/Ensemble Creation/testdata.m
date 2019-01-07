% This is test data for the ensemble builder

lat = -90:4:90;
lon = 0:5:360;
lon(end) = [];

year = repmat( 1:50, 12, 1);
year = year(:);
month = repmat( (1:12)', 50, 1);
time = datetime(year, month, 15);

run = 1:5;
lev = 1;