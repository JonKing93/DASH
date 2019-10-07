function[weights, yloc] = localizationWeights( siteCoord, stateCoord, R, scale)
%% Calculates the weights for covariance localization at a site.
%
% [w, yloc] = dash.localizationWeights( siteCoord, stateCoord, R )
% Calculates covariance localization weights based on user-defined state
% vector coordinates.
%
% [...] = dash.localizationWeights( siteCoord, stateCoord, R, scale )
% Specifies the length scale to use for the localization weights. This
% adjusts how quickly localization weights decrease as they approach the
% cutoff radius. Must be a scalar on the interval (0, 0.5]. Default is 0.5.
%
% [...] = dash.localizationWeights( siteCoord, stateCoord, R, 'optimal' )
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
% siteCoord: The coordinates of the grid nodes that are closest to the
%            observation sites. A two-column matrix. First column
%            is latitude, second is longitude. Supports both 0-360 and 
%            -180 to 180 longitude coordinates. (nObs x 2)
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

% Set defaults
if ~exist('scale','var') || isempty(scale)
    scale = 0.5;
elseif strcmpi(scale, 'optimal')
    scale = sqrt(10/3);
end

% Error check
if ~ismatrix(siteCoord) || size(siteCoord,2) ~= 2
    error('Site coordinates must be a two column matrix.');
elseif ~ismatrix(stateCoord) || size( stateCoord, 2 ) ~= 2
    error('State coordinates must be a matrix with 2 columns.');
elseif ~isscalar(scale) || scale<0 || scale>0.5
    error('The length scale must be a scalar on the interval [0, 0.5].');
end

% Get the localization weights for the state vector
weights = localWeights( siteCoord, stateCoord, R, scale );

% Get the weights between observations (needed for joint ENSRF)
yloc = localWeights( siteCoord, siteCoord, R, scale );

end

%% Helper function

% Get the localization weights for two sets of coordinates
function[weights] = localWeights( siteCoord, stateCoord, R, scale )

% Preallocate the distance between site and nodes
nState = size(stateCoord,1);
nSite = size(siteCoord,1);
dist = NaN(nState, nSite);

% Get the distance between the site and the state nodes
for k = 1:nSite
    dist(:,k) = haversine(siteCoord(k,:), stateCoord);
end

% Get the length scale and covariance localization radius. 
c = scale * R;
Rloc = 2*c;    % Note that Rloc <= R, they are not strictly equal

% Get the indices of sites that are outside/inside the localization radius,
% which is defined as twice the length scale. Split the points inside the 
% radius into values inside or outside length scale.
outRloc = (dist > Rloc);
inScale = (dist <= c);
outScale = (dist > c) & (dist <= Rloc);

% Preallocate the covariance localization weights. Use 1 as the fill value
% so non-localizable sites are not affected by the localization.
weights = ones( nState, nSite );

% Get the weights for each set of points
x = dist / c;
weights(inScale) = polyval([-.25,.5,.625,-5/3,0,1], x(inScale));
weights(outScale) = polyval([1/12,-.5,.625,5/3,-5,4], x(outScale)) - 2./(3*x(outScale));
weights(outRloc) = 0;

% Weights should always be positive. Round-off errors may result in
% small negative weights near the localization radius. Set them to zero.
weights( weights<0 ) = 0;

end