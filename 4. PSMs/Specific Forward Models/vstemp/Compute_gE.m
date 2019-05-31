function [gE] = Compute_gE(phi)
%% Computes gE from latitude
%
% gE = Compute_gE( phi )
%
% ----- Inputs -----
%
% phi: Latitude in degrees. (Scalar)
%
% ----- Outputs -----
%
% gE: Insolation growth response in each month. Ordered from Jan - Dec. (12 x 1)

% ----- Written By -----
% SETW 3/8/13
%
% Cleaned by Jonathan King, 5/22/19

% Error check
if ~isscalar( phi )
    error('phi must be a scalar');
elseif phi > 90 || phi <= -90
    error('phi must be on the interval [-90, 90].');
end

% Preallocate 
gE = NaN(12,1);

% Get latitude in radians
latr = phi*pi/180;

% Use solar declination to compute normalized day length
sd = asin(sin(pi*23.5/180) * sin(pi * (((1:365) - 80)/180)))';

y = -tan(ones(365,1).* latr) .* tan(sd);
y( y >= 1 ) = 1;
y( y <= -1 ) = -1;

hdl = acos(y);
dtsi = (hdl.* sin(ones(365,1).*latr).*sin(sd))+(cos(ones(365,1).*latr).*cos(sd).*sin(hdl));

ndl=dtsi./max(dtsi); 

% Get the cumulative number of days at the end of each month
ndays = [0 31 28 31 30 31 30 31 31 30 31 30 31];
cdays = cumsum(ndays);

% Get the monthly insolation growth modifier. (The sum of normalized day
% length over each month.)
for t = 1:12
    gE(t) = mean(  ndl( cdays(t)+1:cdays(t+1), 1)  );
end

end
