function[Y] = gaspariCohn2D(X, R, scale)
%% Applies a Gaspari-Cohn 5th order polynomial in 2 dimensions for a
% specified cutoff radius and length scale.
%
% weights = gaspariCohn2D(dist, R)
% Determines localization weights based on a cutoff radius. Uses a length
% scale of 0.5
%
% weights = gaspariCohn2D(dist, R, scale)
% Sets the length scale for the Gaspari-Cohn polynomial.
%
% weights = gaspariCohn2D(dist, R, 'optimal')
% Uses a length scale of sqrt(10/3) based on Lorenc (2003).
%
% ----- Inputs -----
%
% X: An numeric array. Cannot contain negative values.
%
% R: The cutoff radius. A positive scalar. Should use the same units as X.
%
% scale: A scalar on the interval (0 0.5]. Used to determine the cutoff
%    radius. If unspecified, scale is set to 0.5 and the localization
%    radius is equal to R. If less than 0.5, the cutoff radius will be
%    smaller than R.
%
% ----- Outputs -----
%
% weights: A vector of localization weights

% Set defaults
if ~exist('scale','var') || isempty(scale)
    scale = 0.5;
elseif dash.string.isflag(scale) && strcmp(scale, 'optimal')
    scale = sqrt(10/3);
end

% Error check
dash.assert.scalarType(R, 'R', 'numeric', 'numeric');
dash.assert.realDefined(R, 'R', false, true);
assert(R>0, 'R must be positive');

dash.assert.scalarType(scale, 'scale', 'numeric', 'numeric');
dash.assert.realDefined(scale, 'scale');
assert(scale>=0&scale<=0.5, 'scale must be on the interval [0 0.5]');

assert(isnumeric(X), 'dist must be numeric');
dash.assert.realDefined(X, 'dist', true, true);
assert(~any(X(:)<0), 'dist cannot have negative elements');

% Get the length scale and localization radius
c = scale * R;
Rloc = 2*c; % Note that Rloc <= R, they are not strictly equal

% Get points inside/outside the radius.
outRloc = (X > Rloc);
inScale = (X <= c);
outScale = (X > c) & (X <= Rloc);

% Preallocate weights
Y = ones( size(X) );

% Apply the polynomial to the distances
x = X / c;
Y(inScale) = polyval([-.25,.5,.625,-5/3,0,1], x(inScale));
Y(outScale) = polyval([1/12,-.5,.625,5/3,-5,4], x(outScale)) - 2./(3*x(outScale));
Y(outRloc) = 0;

% Weights should never be negative. Remove near-zero negative weights
% resulting from round-off errors.
Y( Y<0 ) = 0;

end