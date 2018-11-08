function[weights] = covLocalization( site, coords, R, scale)
%
% weights = covLocalization( site, coords, R )
% Creates a covariance localization with a cutoff radius R. Based on a
% Gaspari-Cohn function.
%
% weights = covLocalization( site, coords, R, 'optimal')
% Uses an optimal length scale of sqrt(10/3) for the localization radius
% based on Lorenc, 2003.
%
% weights = covLocalization( site, coords, R, scale)
% User specified length scale. Scale must be a scalar on the interval (0, 0.5].
%
%
% ----- Inputs -----
% 
% site: The set of site coordinates, latitude x longitude. (nObs x 2)
%
% coords: The state vector coordinates, latitude x longitude.
%         Non-localizable state variables (e.g. global mean) should use NaN
%         coordinates to prevent localization.  (nState x 2)
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
% weights: The localization weights for each site. (nState x nObs)
%
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
% Modified to included variable/optimal length scales. 

% If not specified, set the length scale to 1/2 the localization radius
if ~exist('scale','var')
    scale = 0.5;
else
    % If optimal scale is selected (Lorenc, 2003)
    if strcmpi(scale, 'optimal')   
        scale = sqrt(10/3);
    elseif ~isscalar(scale) || scale<0 || scale>0.5
        error('The length scale must be a scalar on the interval [0, 0.5].');
    end
end       

% Get the distance between the site and the state vector grid nodes
dist = NaN(nState, nObs);
for k = 1:nObs
    dist(:,k) = haversine(site(k,:), coords);
end

% Get the length scale and covariance localization radius.
c = scale * R;
Rloc = 2*c;    % Note that Rloc <= R, they are not strictly equal

% Get the indices of sites that are outside/inside the localization radius,
% which is defined as twice the length scale. Split the points inside the 
% radius into values inside or outside length scale.
% (Note that the localization radius <= R, it is not strictly equal.)
outRloc = (dist > Rloc);
inScale = (dist <= c);
outScale = (dist > c) & (dist <= Rloc);

% Preallocate the covariance localization weights. Use 1 as the fill value
% so non-localizable sites are not affected by the localization.
weights = ones( nState,1 );

% Get the weights for each set of points
x = dist / c;
weights(inScale) = polyval([-.25,.5,.625,-5/3,0,1], x);
weights(outScale) = polyval([1/12,-.5,.625,5/3,-5,4],x) - 2/(3*x);
weights(outRloc) = 0;

% Weights should always be positive. Round-off errors may result in
% small negative weights near the localization radius. Set them to zero.
weights( weights<0 ) = 0;

end