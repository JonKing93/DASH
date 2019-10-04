function[] = errorCheckPSM( obj )
% Error checks a linear PSM
if isempty(obj.slope) || isempty(obj.intercept) || isempty(obj.nH)
    error('The slope, intercept and nH cannot be empty.');
elseif any(isnan(obj.slope)) || any(isnan(obj.intercept)) || any(isnan(obj.varDex))
    error('The slope, intercept, and nH cannot be NaN.');
elseif ~isvector(obj.slope) || ~isvector(obj.varDex) || length(obj.slope)~=length(obj.varDex)
    error('The slope and nH must be vectors with the same number of elements.');
elseif ~isscalar(obj.intercept)
    error('The intercept must be a scalar.');
end
end