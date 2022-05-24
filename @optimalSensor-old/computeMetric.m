function[J] = computeMetric(obj, X)
%% Computes a metric for an ensemble.
% Note: This function is a switch to actual metric functions.
%
% J = obj.computeMetric(X)

% Note: This method is intended as a switch to specific metric methods

if strcmpi(obj.metricType, "mean")
    J = obj.meanMetric(X);
end

end