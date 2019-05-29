function[dJ] = detJacobianBoxCox( y, lambda )
%% Computes the Jacobian determinant of the Box-Cox transform.

% Check lambda is scalar
if ~isscalar(lambda)
    error('lambda must be scalar');
end

% Preallocate the output
dJ = NaN( size(y) );

% Find the negative values
neg = y < 0;

% Jacobian determinant for negative values
dJ(neg) = (1 - y(neg)) .^ (1 - lambda);

% For non-negative values
dJ(~neg) = (1 + y(~neg)) .^ (lambda - 1);

end