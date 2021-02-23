function[J] = meanMetric(obj, X)
%% Computes a sensor metric using a weighted mean

rows = obj.metricArgs.rows;
w = obj.metricArgs.weights;
denom = obj.metricArgs.denom;

J = sum(w.*X(rows,:),1) ./ denom;

end