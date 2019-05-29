function[width] = vstemp( phi, T1, T2, T, varargin )
%% A temperature-only version of VS-Lite
%
% width = vstemp( phi, T1, T2, T )
% Generates ring widths from monthly temperature and insolation. Returns an
% un-normalized chronology. Uses all months to calculate ring widths.
%
% width = vstemp( phi, T1, T2, T, 'intwindow', intwindow )
% Only uses specified months to calculate ring widths.
%
% ----- Inputs -----
%
% phi: Latitude in degrees.
%
% T1: Temperature threshold below which growth is 0.
%
% T2: Temperature threshold above which growth is maximal.
%
% T: Monthly temperatures. For northern hemisphere sites, in order from 
% Jan - Dec. For southern hemisphere sites, July - June. (12 x N)
%
% intwindow: Vector of integers indicating months of seasonal sensitivity.
%    Integers correspond to the rows of T. (For example: [5 6] corresponds to
%    May and June for a NH site, but Nov. and Dec. for a SH site). (nMonth x 1)
%
% ----- Outputs -----
%
% width: Unnormalized ring widths.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
% (Mostly just copied from the vslite code, with some better documentation)

% Intwindow
intwindow = parseInputs( varargin, {'intwindow'}, {1:12}, {[]} );

% Error checking and setup
errCheck( phi, T1, T2, T, intwindow );

% Compute gE, the scaled monthly proxy for insolation:
gE = Compute_gE(phi);

% Flip gE to July - June for SH sites
if phi < 0
    gE = gE( [7:12, 1:6] );
end

% Get the months below T1 and above T2
lessT1 = T < T1;
greatT2 = T > T2;

% Preallocate the temperature response
gT = NaN( size(T) );

% Get the temperature growth responses
gT( lessT1 ) = 0;
gT( greatT2 ) = 1;
gT( ~lessT1 & ~greatT2 ) = ( T(~lessT1 & ~greatT2) - T1 ) ./ (T2 - T1);

% Compute growth rate (temperature response scaled by insolation)
Gr = gE .* gT;

% Get ring width as the sum of the seasonally sensitive months
width = sum( Gr(intwindow,:), 1 );

end

%% Error check the inputs.
function[] = errCheck( phi, T1, T2, T, intwindow )

if ~isscalar( phi )
    error('phi is not a scalar.');
elseif ~isscalar(T1)
    error('T1 is not a scalar');
elseif ~isscalar(T2)
    error('T2 is not a scalar');
elseif T1 > T2
    error('T1 is greater than T2');
elseif ~ismatrix(T) || size(T,1)~=12
    error('T must be a matrix with 12 rows.');
elseif ~isvector(intwindow) || ~isnumeric(intwindow) || any( mod(intwindow,1)~=0 ) || any(intwindow>12) || any(intwindow<1)
    error('intwindow must be a vector of integers on the interval [1, 12]');
elseif numel(unique(intwindow))~=numel(intwindow)
    error('intwindow contains duplicate values.');
end

end
