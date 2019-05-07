function[y] = invExtBoxCox( z, lambda )
%% Implements the inverse extended Box-Cox transformation.

% Check lambda is scalar
if ~isscalar(lambda)
    error('lambda must be scalar');
end

% Preallocate output
y = NaN( size(z) );

% Find the negative values
neg = z < 0;

% Transform negative values
if lambda == 2
    y(neg) = 1 - exp( -z(neg) );
else
    y(neg) = 1 - ( (lambda-2) .* z(neg) + 1) .^ (1 ./ (2 - lambda));
end

% Transform non-negative values
if lambda == 0
    y(~neg) = exp( z(~neg) ) - 1;
else
    y(~neg) = (lambda .* z(~neg)) .^ (1./lambda) - 1;
end

end