function[out] = run(obj, N)
%% Runs an optimal sensor test for the best N sensors.
%
% out = obj.run(N)
%
% ----- Inputs -----
%
% N: How many sensors to find. A scalar positive integer.
%
% ----- Outputs -----

% Check for essential fields
assert(~isempty(obj.X), 'You must specify a prior before you run an optimal sensor test');
assert(obj.hasPSMs || ~isempty(obj.Ye), 'You must specify either PSMs or estimates before running an optimal sensor test');
assert(~isempty(obj.metricType), 'You must specify a metric before running an optimal sensor test.');

% Preallocate, locate R values that need to be filled by PSMs
bestSite = NaN(obj.nSite, 1);
expVar = NaN(obj.nSite, 1);
fill = isnan(obj.R);

% Initialize
R = obj.R;
Ye = obj.Ye;
X = obj.X;

% Unbiased estimator for statistical calculations
unbias = 1/(obj.nEns-1);

% Get the estimates, their deviations, and variance
for s = 1:N
    if obj.hasPSMs
        [Ye, Rpsm] = PSM.estimate(X, obj.F);
        R(fill) = Rpsm(fill);
    end
    [~, Ydev] = dash.decompose(Ye);
    Yvar = unbias * sum(Ydev.^2, 2);
    
    % Get the deviations and variance of the metric/index
    J = obj.computeMetric(X);
    [~, Jdev] = dash.decompose(J);
    Jvar = unbias * sum(Jdev.^2, 2);
    
    % Get the relative change in variance caused by each sensor
    skill = (1/Jvar) * (unbias .* Ydev * Jdev') ./ (Yvar + R);
    
    % The optimal sensor maximizes the change in variance
    expVar(s) = max(skill);
    best = find(skill==expVar(s), 1);
    bestSite(s) = testSites(best);
    
    % Update the ensemble using the optimal sensor
    
    
end

end

