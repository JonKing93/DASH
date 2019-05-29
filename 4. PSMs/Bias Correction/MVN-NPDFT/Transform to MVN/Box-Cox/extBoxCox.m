function[z] = extBoxCox( y, lambda )
%% Implements the extended box-cox transformation. (Yeo and Johnson, 2000)
%
% z = extBoxCox( y, lambda )
%
% ----- Inputs -----
%
% y: A set of data to be transformed
%
% lambda: The Box-Cox parameter.
%
% ----- Outputs -----
%
% z: Transformed data

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check lambda is scalar.
if ~isscalar(lambda)
    error('lambda must be a scalar.');
end

% Preallocate the output
z = NaN( size(y) );

% Find the negative values
neg = y < 0;

% Transform negative values
if lambda == 2
    z( neg ) = log( -y(neg) + 1 );
else
    z( neg ) = -( (-y(neg) + 1) .^ (2-lambda) - 1) ./ (2 - lambda);
end

% Transform non-negative values
if lambda == 0
    z( ~neg ) = log( y(~neg) + 1 );
else
    z( ~neg ) = ( (y(~neg) + 1) .^ (lambda) - 1 ) ./ lambda;
end
   
end