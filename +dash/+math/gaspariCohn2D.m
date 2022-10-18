function[weights] = gaspariCohn2D(distances, R, scale)
%% dash.math.gaspariCohn2D  Implements a Gaspari-Cohn 5th order polynomial in 2 dimensions
% ----------
%   weights = dash.math.gaspariCohn2D(distances, R)
%   Calculates covariance localization weights for a set of distances given
%   a specified cutoff radius. Uses a length scale of 0.5.
%
%   weights = dash.math.gaspariCohn2D(distances, R, scale)
%   Specify the length scale to use for the Gaspari-Cohn polynomial.
%
%   weights = dash.math.gaspariCohn2D(distances, R, 'optimal')
%   Uses a length scale of sqrt(10/3), which was described as optimal by Lorenc (2003).
% ----------
%   Inputs:
%       distances (numeric array): A set of distances. The distances may be in any
%           units, and should not contain negative values. NaN values are
%           permitted.
%       R (positive numeric scalar): The curoff radius. Must use the same
%           units as the distances.
%       scale (numeric scalar | 'optimal'): The length scale for the polynomial. Must
%           be a value on the interval 0 < scale <= 0.5. By default, uses a
%           length scale of 0.5, which sets the localization radius equal
%           to R.
%
%   Outputs:
%       weights (numeric array): Covariance localization weights. Will have
%           the same size as the distances input.
%
% <a href="matlab:dash.doc('dash.math.gaspariCohn2D')">Documentation Page</a>

% Defaults
if ~exist('scale','var') || isempty(scale)
    scale = 0.5;
elseif dash.is.string(scale) && strcmp(scale, 'optimal')
    scale = sqrt(10/3);
end

% Get the length scale and localization radius
c = scale * R;
Rloc = 2*c;  % Note that, depending on scale, Rloc <= R -- they are not strictly equal

% Find points inside and outside the radius and length scale
outsideRadius = distances > Rloc;
insideScale = distances <= c;
inBetween = ~insideScale & ~outsideRadius;

% Preallocate the weights
weights = ones( size(distances) );

% Apply the polynomial to the distances
X = distances / c;
weights(outsideRadius) = 0;
weights(insideScale) = polyval([-.25,.5,.625,-5/3,0,1], X(insideScale));

tapered = X(inBetween) - 2 ./ (3 * X(inBetween));
weights(inBetween) = polyval([1/12,-.5,.625,5/3,-5,4], tapered);

% Weights should never be negative. Remove near-zero negative weights
% resulting from rounding errors.
weights(weights<0) = 0;

end