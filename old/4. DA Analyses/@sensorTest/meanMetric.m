function[J] = meanMetric(obj, A)
%% Calculates an optimal sensor skill metric using a weighted mean
%
% J = obj.meanMetric(A)
%
% ----- Inputs -----
%
% A: The posterior ensemble
%
% ----- Outputs -----
%
% J: The skill metric. A row vector with one element per ensemble member.

% Take the weighted mean
w = obj.metricArgs.weights;
rows = obj.metricArgs.rows;
denom = obj.metricArgs.denom;

A = A(rows,:);
J = sum(w.*A, 1) ./ denom;

end