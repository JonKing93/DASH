function[Y] = linearModel( X, slopes, intercept )
% The linear model function used by a linearPSM
%
% Y = linearPSM.linearModel( X, slopes, intercept )
%
% ----- Inputs -----
%
% X: A set of data values. (nVar x nEns)
%
% slopes: The linear multiplicative constants (nVar x 1)
%
% intercept: The linear additive constant. A scalar.

% Error check
if ~ismatrix(X) || ~isnumeric(X)
    error('X must be a numeric matrix');
elseif ~iscolumn(slopes) || length(slopes)~=size(X,1) || ~isnumeric(slopes)
    error('slopes must be a numeric column vector with one element per row in X.');
elseif ~isnumeric(intercept) || ~isscalar(intercept)
    error('intercept must be a numeric scalar.');
end

% Apply the model
Y = sum( X.*slopes, 1 ) + intercept;

end
    
    