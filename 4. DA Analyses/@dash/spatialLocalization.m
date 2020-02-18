function[weights, yloc] = spatialLocalization( siteCoord, stateCoord, R, scale)
%% Calculates the weights for covariance localization at a site.
%
% [w, yloc] = dash.spatialLocalization( siteCoord, ensMeta, R )
% Calculates covariance localization weights for an ensemble.
%
% [...] = dash.spatialLocalization( siteCoord, stateCoord, R )
% Calculates covariance localization weights for user-defined state
% coordinates.
%
% [...] = dash.spatialLocalization( siteCoord, stateCoord, R, scale )
% Specifies the length scale to use for the localization weights. This
% adjusts how quickly localization weights decrease as they approach the
% cutoff radius. Must be a scalar on the interval (0, 0.5]. Default is 0.5.
%
% [...] = dash.spatialLocalization( siteCoord, stateCoord, R, 'optimal' )
% Uses the optimal length scale of sqrt(10/3) based on Lorenc, 2003.
%
%
% ***** Explanation of length scales and R
%
% The length scale c, is used to define the behavior of the localization.
% For |  distance <= c,       Full covariance is retained
%     |  c < distance < 2*c,  Covariance retention decreases from 1 to 0 with distance
%     |  2c < distance,       No covariance is retained
%
% Rloc = 2c is the localization radius. It is a more stringent requirement
% than R, the cutoff radius. Thus, Rloc <= R, which requires  0 < scale <= 1/2
%
% Essentially, R is the radius at which covariance is required to be zero,
% while Rloc is the (more strict) radius at which covariance actually is 0.
%
% *****
%
% ----- Inputs -----
% 
% siteCoord: The coordinates observation sites. A two-column matrix. First 
%            is latitude, second is longitude. Supports both 0-360 and 
%            -180 to 180 longitude coordinates. (nObs x 2)
%
%           Ideally, site coordinates are the coordinates of the model grid
%           nodes closest to the individual sites. However, when using
%           multiple grids, the actual site coordinates are a good approximation.
%
% ensMeta: An ensemble metadata object.
% 
% stateCoord: A set of state vector coordinates. A two column matrix. First
%     column is latitude, second is longitude. Supports both 0-360 and
%     180 to -180 longitude coordinates.
%
% R: The cutoff radius. All covariance outside of this radius will be
%    eliminated.
%
% scale: A scalar on the interval (0, 0.5]. Used to determine the
%        localization radius. If unspecified, scale is set to 0.5 and the
%        localization radius is equivalent to R.
%
% ----- Outputs -----
%
% w: The localization weights between each site and each state vector element. (nState x nObs)
%
% yloc: The localization weights between the observations sites. (Required
%       localization with a joint update scheme. (nObs x nObs)

% ----- Sources -----
% 
% Based on the approach of Hamill et al., 2001
% https://doi.org/10.1175/1520-0493(2001)129<2776:DDFOBE>2.0.CO;2
%
% ----- Written By -----
% 
% Original function by R. Tardif, Dept. Atmos. Sci.,  Univ. of Washington
% for the Last Millennium Reanalysis.
%
% Adapted for MATLAB by Jonathan King, Dept. Geoscience, University of
% Arizona, 08 Nov 2018.
%
% Modified to included variable/optimal length scales by Jonathan King.
%
% Y localization weights by Jonathan King

% Get defaults
if ~exist('scale','var')
    scale = [];
end
if isa(stateCoord, 'ensembleMetadata')
    if ~isscalar(stateCoord)
        error('ensMeta must be a scalar ensembleMetadata object.');
    end
    stateCoord = stateCoord.coordinates;
end

% Error check
if ~ismatrix(siteCoord) || size(siteCoord,2) ~= 2
    error('Site coordinates must be a two column matrix.');
elseif ~ismatrix(stateCoord) || size( stateCoord, 2 ) ~= 2
    error('State coordinates must be a matrix with 2 columns.');
end

% Get the distances
wdist = haversine( siteCoord, stateCoord );
ydist = haversine( siteCoord, siteCoord );

% Use a Gaspari-Cohn polynomial to get the localization weights
weights = gaspariCohn( wdist, R, scale );
yloc = gaspariCohn( ydist, R, scale );

end