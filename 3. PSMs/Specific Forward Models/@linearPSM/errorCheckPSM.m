function[] = errorCheckPSM( obj )
% Error checks a linear PSM
if isempty(obj.slopes) || isempty(obj.intercept) || isempty(obj.Hlim)
    error('The slope, intercept and Hlim cannot be empty.');
elseif any(isnan(obj.slopes)) || any(isnan(obj.intercept)) || any(isnan(obj.Hlim))
    error('The slope, intercept, and Hlim cannot be NaN.');
elseif ~ismatrix( obj.Hlim ) || size(obj.Hlim,2)~=2
    error('Hlim must be a 2-column matrix.');
elseif ~isvector(obj.slopes) || length(obj.slopes) ~= size(obj.Hlim,1)
    error('slope and be a vector with the same number of elements as rows in Hlim.');
elseif ~isscalar(obj.intercept)
    error('The intercept must be a scalar.');
end
end