function [trw] = VSLite4dash(phi,T1,T2,M1,M2,T,P,standard,Tclim,varargin)
%% VS-Lite optimized for the Dash framework
%
% trw = VSLite4dash(phi,T1,T2,M1,M2,T,P,standard,Tclim)
% gives just simulated tree ring as ouput.
%
% [...] = VSLite4dash( ..., 'lbparams', lbparams )
% Specifies the parameters of the leaky bucket model.
%
% [...] = VSLite4dash( ..., 'intwindow', intwindow )
% Specify the growth response window. This is the window used to determine
% seasonal sensitivity.
%
% [...] = VSLite4dash( ..., 'hydroclim', H )
% Specifies whether P or M is provided as input.
%
% ----- Inputs -----
%
% phi: Site latitude in degrees N
%
% T1: Scalar temperature threshold below which growth response is 0. (in Degrees C)
% T2: Scalar temperature threshold above which growth response is 1. (degrees C)
% M1: Scalar soil moisture threshold below which growth response is 0. (in v/v)
% M2: Scalar soil moisture threshold above which growth response is 1. (in v/v)
% *** Note that T1, T2, M1, and M2 may be estimated using estimate_vslite_params_v2_5.m 
%
% T = (12 x nEns) matrix of ordered mean monthly temperatures (in
% degrees C). For a Northern Hemisphere site, the months should be in order
% from January to December in the year of growth. For a Southern Hemisphere
% site the months should be in order from July in the starting year of
% growth to June of the next year.
%
% P = (nMonth x nEns) matrix of ordered accumulated monthly precipitation
% (in mm). Follows the same month ordering scheme as T.
%
% standard: A 2x1 numeric vector. First element is the mean width to use in
% ring width standardization. Second element is the standard deviation.
% Leave empty for no standardization.
%
% Tclim: A monthly temperature climatology to use for the leaky bucket
% model. (12 x 1).
% 
% lbparams:  Parameters of the Leaky Bucket model of soil moisture. An
%           8 x 1 vector in the following order.
%                   Mmax: scalar maximum soil moisture content (in v/v),
%                     default value is 0.76
%                   Mmin: scalar minimum soil moisture (in v/v), default
%                     value is 0.01
%                   alph: scalar runoff parameter 1 (in inverse months),
%                     default value is 0.093
%                   m_th: scalar runoff parameter 3 (unitless), default
%                     value is 4.886
%                   mu_th: scalar runoff parameter 2 (unitless), default
%                     value is 5.80
%                   rootd: scalar root/"bucket" depth (in mm), default
%                     value is 1000
%                   M0: initial value for previous month's soil moisture at
%                     t = 1 (in v/v), default value is 0.2
%                   substep: logical 1 or 0; perform monthly substepping in
%                     leaky bucket (1) or not (0). Default value is 0.
%
%   intwindow: A 2x1 vector indicating which month's growth responses should
%              be integrated. 
%
%   H: A single character indicating whether P (precipitation) or M (soil
%   moisture) is provided as input. If M, then the leaky bucket model is
%   disabled and the value of M is used to calculate growth.


% ----- References -----
%
% For more detailed documentation, see:
% 1) Tolwinski-Ward et al., An efficient forward model of the climate
% controls on interannual variation in tree-ring width, Climate Dynamics (2011)
% DOI: 10.1007/s00382-010-0945-5
%
% 2) Tolwinski-Ward et al., Erratum to: An efficient forward model of the climate
% controls on interannual variation in tree-ring width, Climate Dynamics (2011)
% DOI: 10.1007/s00382-011-1062-9
%
% 3) Tolwinski-Ward et al., Bayesian parameter estimation and
% interpretation for an intermediate model of tree-ring width, Clim. Past
% (2013), DOI: 10.5194/cp-9-1-2013
%
% 4) Documentation available with the model at http://www.ncdc.noaa.gov/paleo/softlib/softlib.html

% Parse the inputs and set the defaults
[lbparams, intwindow, hydroclim] = parseInputs( varargin, {'lbparams','intwindow','hydroclim'}, ...
        {[0.76, 0.01, 0.093, 4.886, 5.80, 1000, 0.2, 0], 1:12, 'P'}, ...
        {[],[],{'P','M'}} );
    
% Error check the inputs
errCheck( phi, T1, T2, M1, M2, T, P, standard, lbparams, intwindow );
    
% Use the original VSLite variable names
Mmax = lbparams(1);
Mmin = lbparams(2);
alph = lbparams(3);
m_th = lbparams(4);
mu_th = lbparams(5);
rootd = lbparams(6);
M0 = lbparams(7);
substep = lbparams(8);

% Preallocate growth responses and soil moisture variables.
nEns = size(T,2);
gT = NaN(12,nEns);
gM = NaN(12,nEns);
M = NaN(12,nEns);

% Permute SH months to match the original VS-Lite scheme in which the array
% always proceeds from January to December. (This is neccesary because it
% affects the insolation gE growth term).
if phi < 0
    T = T([7:12, 1:6], :);
    P = P([7:12, 1:6], :);
    intwindow(intwindow>6) = intwindow(intwindow>6)-6;
    intwindow(intwindow<6) = intwindow(intwindow<6)+6;
end

% Load in or estimate soil moisture:
if strcmp(hydroclim,'M')
    % Read in soil moisture:
    M = P;
else
    % Compute soil moisture:
    if substep == 1
        M = leakybucket_submonthly(nEns,phi,T,P,Mmax,Mmin,alph,m_th,mu_th,rootd,M0,Tclim);
    elseif substep == 0
        M = leakybucket_monthly(nEns,phi,T,P,Mmax,Mmin,alph,m_th,mu_th,rootd,M0,Tclim);
    elseif substep ~=1 && substep ~= 0
        disp('''substep'' must either be set to 1 or 0.');
        return
    end
end

% Compute gE, the scaled monthly proxy for insolation:
gE = Compute_gE(phi);

% Permute gE for the southern hemisphere
if phi < 0
    gE = gE([7:12, 1:6]);
end

% Get the months that are below T1 and above T2
lessT1 = T < T1;
greatT2 = T > T2;

% Get the temperature growth responses
gT( lessT1 ) = 0;
gT( greatT2 ) = 1;
gT( ~lessT1 & ~greatT2 ) = ( T(~lessT1 & ~greatT2) - T1 ) ./ (T2 - T1);

% Get the months that are below M1 and above M2
lessM1 = M < M1;
greatM2 = M > M2;

% Get the moisture growth responses
gM(lessM1) = 0;
gM(greatM2) = 1;
gM(~lessM1 & ~greatM2) = ( M(~lessM1 & ~greatM2) - M1 ) ./ (M2 - M1);

% Compute Growth rate
Gr = gE .* min( gT, gM );

% Grow the tree rings
width = sum( Gr(intwindow,:), 1);

% Standardize the proxy series if a standardization is provided
if ~isempty(standard)
    trw = (width - standard(1)) / standard(2);
    
% Otherwise return the raw widths (for the setStandardization method)
else
    trw = width;
end

end


%% Subroutines

% Error check
function[] = errCheck( phi, T1, T2, M1, M2, T, P, standard, lbparams, intwindow )

if ~isscalar(phi) || phi<-90 || phi>90
    error('phi must be a scalar on the interval [-90, 90]');
end
if ~isscalar(T1) || ~isscalar(T2) || ~isscalar(M1) || ~isscalar(M2)
    error('T1, T2, M1, and M2 must all be scalars.');
end
if size(T,1)~=12
    error('T must have 12 rows. (One for each month).');
elseif size(P,1)~=12
    error('P must have 12 rows. (One for each month).');
elseif size(T,2) ~= size(P,2)
    error('T and P must have the same number of columns. (One for each ensemble member.');
elseif ~isempty(standard) && (numel(standard)~=2 || ~isnumeric(standard))
    error('standard must be a numeric vector with two elements or empty.');
elseif numel(lbparams)~=8 || ~isvector(lbparams) || ~isnumeric(lbparams)
    error('lbparams must be a numeric vector with 8 elements.');
end

% Int window
if ~isvector(intwindow) || ~isnumeric(intwindow) || any(intwindow<1) || any(intwindow>12)
    error('intwindow must be a numeric vector on the interval [1, 12]');
elseif any( mod(intwindow,1)~=0 )
    error('All elements in intwindow must be integers.');
elseif numel(unique(intwindow)) ~= numel(intwindow)
    error('intwindow cannot contain duplicate elements.');
end
    
end

% Leaky Bucket with substepping
function [M,potEv,ndl,cdays] = leakybucket_submonthly(nEns,phi,T,P,...
    Mmax,Mmin,alph,m_th,mu_th,rootd,M0,Tclim)
% leackybucket_submonthly.m - Simulate soil moisture; substeps within monthly timesteps
% to better capture nonlinearities and improve moisture estimates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage: [M,potEv,ndl,cdays] = leakybucket_submonthly(syear,eyear,phi,T,P,...
%                   Mmax,Mmin,alph,m_th,mu_th,rootd,M0)
%    outputs simulated soil moisture and potential evapotranspiration.
%
% Inputs:
%   syear = start year of simulation.
%   eyear = end year of simulation.
%   phi = latitude of site (in degrees N)
%   T = (12 x nEns) matrix of ordered mean monthly temperatures (in degEes C)
%   P = (12 x nEns) matrix of ordered accumulated monthly precipitation (in mm)
%   Mmax = scalar maximum soil moisture held by the soil (in v/v)
%   Mmin = scalar minimum soil moisture (for error-catching) (in v/v)
%   alph = scalar runoff parameter 1 (in inverse months)
%   m_th = scalar runoff parameter 3 (unitless)
%   mu_th = scalar runoff parameter 2 (unitless)
%   rootd = scalar root/"bucket" depth (in mm)
%   M0 = initial value for previous month's soil moisture at t = 1 (in v/v)
%
% Outputs:
%   M = soil moisture computed via the CPC Leaky Bucket model (in v/v, 12 x nEns)
%   potEv = potential evapotranspiration computed via Thornthwaite's 1947 scheme (in mm)
%
% SETW+ N. Graham and K. Georgakakos 2011

% modified by Nick G. and K. Georgakakos - to sub-step the monthly steps. Also this version has added
% soil moisture initial conditions for restarts, or spin-up.  Hands back monthly soil moisture
% and summer soil moisture as well - see varargout.  Nick G. 2011/06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Storage for growth response output variables (size [12 x Nyears]):
M   = NaN(12,nEns);
potEv = NaN(12,nEns);

% ADDED BY NICK
if(M0 < 0.)
    M0=200/rootd;
end

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
nhrs = 24*acosd(1-mmm)/180; % the number of hours in the day in the middle of the month
L = (ndays(2:13)/30).*(nhrs/12); % mean daylength in each month.

% Pre-calculation of istar and I, using input T to compute the climatology:
Tm=Tclim;
if length(Tm) ~=12
    error(['problem with creating T climatology for computing istar ' ...
           'and I'])
elseif length(Tm) ==12
    istar=(Tm./5).^1.514;istar(Tm<0)=0;
    I=sum(istar);
end
% precalculation of the exponent alpha in the Thornwaite (1948) equation:
a = (6.75e-7)*I^3 - (7.71e-5)*I^2 + (1.79e-2)*I + .49;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% -- year cycle -- %%%%
% syear = start (first) year of simulation
% eyear = end (last) year of simulation
% cyear = year the model is currently working on
% iyear = index of simulation year

for cyear=1:nEns      % begin cycling over years
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for t = 1:12  % begin cycling over months in a year
        %%%%% Compute potential evapotranspiration for current month after Thornthwaite:
        Ep = NaN;
        if T(t,cyear) < 0
            Ep = 0;
        elseif T(t,cyear)>=0 && T(t,cyear) < 26.5
            Ep = 16*L(t)*(10*T(t,cyear)/I)^a;
        elseif T(t,cyear) >= 26.5
            Ep = -415.85 + 32.25*T(t,cyear) - .43* T(t,cyear)^2;
        end
        potEv(t,cyear) = Ep;
        %%%%% Now calculate soil moisture according to the CPC Leaky Bucket model
        %%%%% (see J. Huang et al, 1996). Set n-steps according to 2 mm increments
        %%%%% have to update alpha and Ep as well - 2 mm increments came from
        %%%%% testing by K. Georgakakos, but one could use 5 or more, with less "accurate" results.
        %%%%% Stepping is necessary because the parametization is linearized around init condition.
        %%%%%%%%%%%%%%%%%
        dp = 2.0; % mm of precip per increment
        nstep = floor(P(t,cyear)/dp)+1; % number of sub-monthly substeps
        Pinc = P(t,cyear)/nstep; % precip per substep
        alphinc = alph/nstep; % runoff rate per substep time interval
        Epinc = Ep/nstep; % potential evapotrans per substep.
        %%%%%%%%%%%%%%%%%
        % handling for sm_init
        if (t > 1)
            M0=M(t-1,cyear);
        elseif (t == 1 && cyear > 1)
            M0=M(12,cyear-1);
        end
        sm0=M0;
        
        for istep=1:nstep
            % evapotranspiration:
            Etrans = Epinc*sm0*rootd/(Mmax*rootd);
            % groundwater loss via percolation:
            G = mu_th*alphinc/(1+mu_th)*sm0*rootd;
            % runoff; contributions from surface flow (1st term) and subsurface (2nd term)
            R = Pinc*(sm0*rootd/(Mmax*rootd))^m_th + (alphinc/(1+mu_th))*sm0*rootd;
            dWdt = Pinc - Etrans - R - G;
            sm1 = sm0 + dWdt/rootd;
            %
            sm0=max(sm1,Mmin);
            sm0=min(sm0,Mmax);
        end
        M(t,cyear) = sm0;
        % error-catching:
        if M(t,cyear) <= Mmin; M(t,cyear) = Mmin; end
        if M(t,cyear) >= Mmax; M(t,cyear) = Mmax; end
        if isnan(M(t,cyear))==1; M(t,cyear) = Mmin; end
    end % end month (t) cycle
end % end year cycle

end

% Leaky Bucket without substepping
function [M,potEv,ndl,cdays] =...
    leakybucket_monthly(nEns,phi,T,P,Mmax,Mmin,alph,m_th,mu_th,rootd,M0,Tclim)
% leackybucket_monthly.m - Simulate soil moisture with coarse monthly time step.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage: [M,potEv,ndl,cdays] = leakybucket_monthly(syear,eyear,phi,T,P,Mmax,Mmin,alph,m_th,mu_th,rootd,M0)
%    outputs simulated soil moisture and potential evapotranspiration.
%
% Inputs:
%   syear = start year of simulation.
%   eyear = end year of simulation.
%   phi = latitude of site (in degrees N)
%   T = (12 x nEns) matrix of ordered mean monthly temperatures (in degEes C)
%   P = (12 x nEns) matrix of ordered accumulated monthly precipitation (in mm)
%   Mmax = scalar maximum soil moisture held by the soil (in v/v)
%   Mmin = scalar minimum soil moisture (for error-catching) (in v/v)
%   alph = scalar runoff parameter 1 (in inverse months)
%   m_th = scalar runoff parameter 3 (unitless)
%   mu_th = scalar runoff parameter 2 (unitless)
%   rootd = scalar root/"bucket" depth (in mm)
%   M0 = initial value for previous month's soil moisture at t = 1 (in v/v)
%
% Outputs:
%   M = soil moisture computed via the CPC Leaky Bucket model (in v/v, 12 x nEns)
%   potEv = potential evapotranspiration computed via Thornthwaite's 1947 scheme (in mm)
%
% SETW 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Storage for output variables (size [12 x Nyears]):
M  = NaN(12,nEns);
potEv = NaN(12,nEns);

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
nhrs = 24*acosd(1-mmm)/180; % the number of hours in the day in the middle of the month
L = (ndays(2:13)/30).*(nhrs/12); % mean daylength in each month.

% Pre-calculation of istar and I, using input T to compute the climatology:
Tm = Tclim;
if length(Tm) ~=12
    error(['problem with creating T climatology for computing istar ' ...
           'and I'])
elseif length(Tm) ==12
    istar = (Tm./5).^1.514; istar(Tm<0)=0;
    I=sum(istar);
end
% precalculation of the exponent alpha in the Thornwaite (1948) equation:
a = (6.75e-7)*I^3 - (7.71e-5)*I^2 + (1.79e-2)*I + .49;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% -- year cycle -- %%%%
% syear = start (first) year of simulation
% eyear = end (last) year of simulation
% cyear = year the model is currently working on
% iyear = index of simulation year

for cyear=1:nEns     % begin cycling over years
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for t = 1:12  % begin cycling over months in a year
        %%%%% Compute potential evapotranspiration for current month after Thornthwaite:
        Ep = NaN;
        if T(t,cyear) < 0
            Ep = 0;
        elseif T(t,cyear)>=0 && T(t,cyear) < 26.5
            Ep = 16*L(t)*(10*T(t,cyear)/I)^a;
        elseif T(t,cyear) >= 26.5
            Ep = -415.85 + 32.25*T(t,cyear) - .43* T(t,cyear)^2;
        end
        potEv(t,cyear) = Ep;
        %%%%% Now calculate soil moisture according to the CPC Leaky Bucket model
        %%%%% (see J. Huang et al, 1996).
        if t > 1
            % evapotranspiration:
            Etrans = Ep*M(t-1,cyear)*rootd/(Mmax*rootd);
            % groundwater loss via percolation:
            G = mu_th*alph/(1+mu_th)*M(t-1,cyear)*rootd;
            % runoff; contributions from surface flow (1st term) and subsurface (2nd term)
            R = P(t,cyear)*(M(t-1,cyear)*rootd/(Mmax*rootd))^m_th +...
                (alph/(1+mu_th))*M(t-1,cyear)*rootd;
            dWdt = P(t,cyear) - Etrans - R - G;
            M(t,cyear) = M(t-1,cyear) + dWdt/rootd;
        elseif t == 1 && cyear > 1
            % evapotranspiration:
            Etrans = Ep*M(12,cyear-1)*rootd/(Mmax*rootd);
            % groundwater loss via percolation:
            G = mu_th*alph/(1+mu_th)*M(12,cyear-1)*rootd;
            % runoff; contributions from surface flow (1st term) and subsurface (2nd term)
            R = P(t,cyear)*(M(12,cyear-1)*rootd/(Mmax*rootd))^m_th +...
                (alph/(1+mu_th))*M(12,cyear-1)*rootd;
            dWdt = P(t,cyear) - Etrans - R - G;
            M(t,cyear) = M(12,cyear-1) + dWdt/rootd;
        elseif t == 1 && cyear == 1
            if M0 < 0; M0 = .20; end
            % evapotranspiration (take initial soil moisture value to be 200 mm)
            Etrans = Ep*M0*rootd/(Mmax*rootd);
            % groundwater loss via percolation:
            G = mu_th*alph/(1+mu_th)*(M0*rootd);
            % runoff; contributions from surface flow (1st term) and subsurface (2nd term)
            R = P(t,cyear)*(M0*rootd/(Mmax*rootd))^m_th + (alph/(1+mu_th))*M0*rootd;
            dWdt = P(t,cyear) - Etrans - R - G;
            M(t,cyear) = M0 + dWdt/rootd;
        end
        % error-catching:
        if M(t,cyear) <= Mmin; M(t,cyear) = Mmin; end
        if M(t,cyear) >= Mmax; M(t,cyear) = Mmax; end
        if isnan(M(t,cyear))==1; M(t,cyear) = Mmin; end
    end % end month (t) cycle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % end year cycle
end

% Insolation growth response
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
%%%%%%%%%%%%%%%
end