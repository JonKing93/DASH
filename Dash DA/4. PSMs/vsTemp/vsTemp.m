function[trw] = vsTemp(syear, eyear, phi, T1, T2, T, varargin)
%% Like VS-Lite, but does not consider moisture sensitivity.
%
% trw = vsTemp(syear, eyear, phi, T1, T2, T)
% Calculates tree ring width based on temperature
%
% trw = vsTemp( ..., 'intwindow', intwindow )
% Specifies the integraton window. Just like VSLite_v2_5.m
%
% ----- Inputs -----
%
% syear: Start year
%
% eyear: End year
%
% phi: Latitude
%
% T1: scalar temperature threshold below which temp. growth response is zero (in deg. C)
%
% T2: scalar temperature threshold above which temp. growth response is one (in deg. C)
%
% T: (12 x Nyrs) matrix of ordered mean monthly temperatures (in degrees C)
%
% intwindow: Integration window. 2 x 1 vector with the starting month and
%       ending month of growth.
%
% ----- Outputs -----
%
% trw: Standardized tree ring width

% Get the number of years
iyear = syear:eyear;
nyrs = length(syear:eyear);

% Default Integration window
I_0 = 1;
I_f = 12;

% User specified integration window
intwindow = parseInputs( varargin, {'intwindow'}, {[]}, {[]} );
if ~isempty(intwindow)
    I_0 = intwindow(1);
    I_f = intwindow(end);
end

% Preallocate outputs
Gr = NaN(12,nyrs);
gT = NaN(12,nyrs);

%% Get the growth rate for each year

% Compute gE, the scaled monthly proxy for insolation:
gE = Compute_gE(phi);

% For each month of each year
for cyear=1:length(iyear)
    for t = 1:12
        
        % Get the temperature
        x = T(t,cyear);
        
        % Get the growth response
        if (x < T1)
            gT(t,cyear) = 0;
        elseif (x >= T1) && (x <= T2)
            gT(t,cyear) = (x - T1)/(T2 - T1);
        elseif (x >= T2)
            gT(t,cyear) = 1;
        end
    end
    
    % Get the overall growth rate for the year
    Gr(:,cyear) = gE .* gT(:,cyear);
end

%% Get the width from the growth response based on hemisphere and integration window

width = NaN*ones(length(syear:eyear),1);
if phi>0 % Northern Hemisphere:
    if I_0<0 % if we include part of the previous year in each year's modeled growth:
        startmo = 13+I_0;
        endmo = I_f;
        % use average of growth data across modeled years to estimate first year's growth due
        % to previous year:
        width(1) = sum(Gr(1:endmo,1)) + sum(mean(Gr(startmo:12,:),2));
        for cyear = 2:length(syear:eyear)
            width(cyear) = sum(Gr(startmo:12,cyear-1)) + sum(Gr(1:endmo,cyear));
        end
    else % no inclusion of last year's growth conditions in estimates of this year's growth:
        startmo = I_0+1;
        endmo = I_f;
        for cyear = 1:length(syear:eyear)
            width(cyear) = sum(Gr(startmo:endmo,cyear));
        end
    end
elseif phi<0 % if site is in the Southern Hemisphere:
    % (Note: in the Southern Hemisphere, ring widths are dated to the year in which growth began!)
    startmo = 7+I_0; % (eg. I_0 = -4 in SH corresponds to starting integration in March of cyear)
    endmo = I_f-6; % (eg. I_f = 12 in SH corresponds to ending integraion in June of next year)
    for cyear = 1:length(syear:eyear)-1
        width(cyear) = sum(Gr(startmo:12,cyear)) + sum(Gr(1:endmo,cyear+1));
    end
    % use average of growth data across modeled years to estimate last year's growth due
    % to the next year:
    width(length(syear:eyear)) = sum(Gr(startmo:12,length(syear:eyear)))+...
        sum(mean(Gr(1:endmo,:),2));
end

% Standardize the width
trw = ((width-mean(width))/std(width))';

end

%% Subroutines

% Compute the growth scaling factor from daylength
function [gE] = Compute_gE(phi)
% Just what it sounds like... computes just gE from latitude a la VS-Lite,
% but without all the other stuff.
%
% Usage: gE = Compute_gE(phi)
%
% SETW 3/8/13

%
gE = NaN(12,1);
%
% Compute normalized daylength (neglecting small difference in calculation for leap-years)
latr = phi*pi/180;  % change to radians
ndays = [0 31 28 31 30 31 30 31 31 30 31 30 31];
cdays = cumsum(ndays);
sd = asin(sin(pi*23.5/180) * sin(pi * (((1:365) - 80)/180)))';   % solar declination
y = -tan(ones(365,1).* latr) .* tan(sd);
if ~isempty(find(y>=1,1))
    y(y>=1) = 1;
end
if ~isempty(find(y<=-1,1))
    y(y<=-1) = -1;
end
hdl = acos(y);
dtsi = (hdl.* sin(ones(365,1).*latr).*sin(sd))+(cos(ones(365,1).*latr).*cos(sd).*sin(hdl));
ndl=dtsi./max(dtsi); % normalized day length

% calculate mean monthly daylength (used for evapotranspiration in soil moisture calcs)
jday = cdays(1:12) +.5*ndays(2:13);
m_star = 1-tand(phi)*tand(23.439*cos(jday*pi/182.625));
mmm = NaN*ones(1,12);
for mo = 1:12
    if m_star(mo) < 0
        mmm(mo) = 0;
    elseif m_star(mo) >0 && m_star(mo) < 2
        mmm(mo) = m_star(mo);
    elseif m_star(mo) > 2
        mmm(mo) = 2;
    end
end
%nhrs = 24*acosd(1-mmm)/180; % the number of hours in the day in the middle of the month
%L = (ndays(2:13)/30).*(nhrs/12);
%
for t = 1:12
    gE(t) = mean(ndl(cdays(t)+1:cdays(t+1),1));
end

end