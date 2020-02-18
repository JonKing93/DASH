function[weights] = gaspariCohn( dist, R, scale )
% Uses a gaspariCohn 5th order polynomial to determine localization weights
%
% [weights] = gaspariCohn( dist, R, scale )

% Set defaults
if ~exist('scale','var') || isempty(scale)
    scale = 0.5;
elseif strcmpi(scale, 'optimal')
    scale = sqrt(10/3);
end

% Error check
if ~isscalar(scale) || ~isnumeric(scale) || scale<0 || scale>0.5
    error('The length scale must be a scalar on the interval [0, 0.5].');
elseif ~isscalar(R) || ~isnumeric(R) || R<0
    error('R must be a positive numeric scalar.');
elseif ~isnumeric(dist) || any(dist(:)<0)
    error('dist must be a numeric array with no negative values.');
end

% Get the length scale and covariance localization radius. 
c = scale * R;
Rloc = 2*c;    % Note that Rloc <= R, they are not strictly equal

% Get points that are inside/outside the localization radius. Points inside
% the radius are split into inside / outside the length scale
outRloc = (dist > Rloc);
inScale = (dist <= c);
outScale = (dist > c) & (dist <= Rloc);

% Preallocate weights
weights = ones( size(dist) );

% Apply the polynomial to the distances
x = dist / c;
weights(inScale) = polyval([-.25,.5,.625,-5/3,0,1], x(inScale));
weights(outScale) = polyval([1/12,-.5,.625,5/3,-5,4], x(outScale)) - 2./(3*x(outScale));
weights(outRloc) = 0;

% Weights should never be negative. Remove near-zero negative weights
% resulting from round-off errors.
weights( weights<0 ) = 0;

end