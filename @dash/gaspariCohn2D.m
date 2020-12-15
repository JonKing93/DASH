function[weights] = gaspariCohn2D(dist, R, scale)
%% Uses Gaspari-Cohn 5th order polynomial in 2 dimensions to determine
% localization weights
%
% weights = gaspariCohn2D(dist, R, scale)
%
% ----- Inputs -----
%
% dist: A vector of distances in kilometers
%
% R: 

% Set defaults
if ~exist('scale','var') || isempty(scale)
    scale = 0.5;
elseif dash.isstrflag(scale) && strcmp(scale, 'optimal')
    scale = sqrt(10/3);
end

% Error check
dash.assertScalarType(R, 'R', 'numeric', 'numeric');
dash.assertRealDefined(R, 'R');
assert(R>0, 'R must be positive');

dash.assertScalarType(scale, 'scale', 'numeric', 'numeric');
dash.assertRealDefined(scale, 'scale');
assert(scale>=0&scale<=0.5, 'scale must be on the interval [0 0.5]');

dash.assertVectorTypeN(dist, 'numeric', [], 'dist');
dash.assertRealDefined(dist, 'dist', true, true);
assert(~any(dist<0), 'dist cannot have negative elements');

% Get the length scale and localization radius
c = scale * R;
Rloc = 2*c; % Note that Rloc <= R, they are not strictly equal

% Get points inside/outside the radius.
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