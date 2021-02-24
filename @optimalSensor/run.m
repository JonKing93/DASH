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

% Error check
dash.assertScalarType(N, 'N', 'numeric', 'numeric');
dash.assertPositiveIntegers(N, 'N', false, false);
assert(N<=obj.nSite, sprintf('N cannot be larger than the number of sensor sites (%.f)',obj.nSite));

% Preallocate. Locate R values that need to be filled by PSMs
bestSite = NaN(obj.nSite, 1);
expVar = NaN(obj.nSite, 1);
fill = isnan(obj.R);

% Initialize
R = obj.R;
[Xmean, Xdev] = dash.decompose(obj.X);
use = true(obj.nSite, 1);

if obj.hasPSMs
    Ye = NaN(obj.nSite, obj.nEns);
else
    [~, Ydev] = dash.decompose(obj.Ye);
end

% Unbiased estimator for statistical calculations
unbias = 1/(obj.nEns-1);

% If not using PSMs, get the deviations for the sites being tested
for s = 1:N
    if ~obj.hasPSMs
        Ydev = Ydev(use,:);
        
    % Otherwise, generate estimate deviations using the PSMs
    else
        X = Xmean + Xdev;
        
        k = use & fill;
        [Ypsm, Rpsm] = PSM.computeEstimates(X, obj.F(k));
        checkPSMOutput(Ypsm, Rpsm);
        Ye(k,:) = Ypsm;
        R(k) = Rpsm;
        
        k = use & ~fill;
        Ypsm = PSM.computeEstimates(X, obj.F(k));
        checkPSMOutput(Ypsm);
        Ye(k,:) = Ypsm;
        
        [~, Ydev] = dash.decompose(Ye(use,:));
    end
    
    % Get the variance of the deviations and the metric
    Yvar = unbias * sum(Ydev.^2, 2);
    Jdev = obj.computeMetric(X);
    Jvar = unbias * sum(Jdev.^2, 2);
    
    % Get the relative change in variance caused by each sensor
    Rs = R(use);
    skill = (1/Jvar) * (unbias .* Ydev * Jdev') ./ (Yvar + Rs);
    
    % The optimal sensor maximizes the change in variance
    sites = find(use);
    maxSkill = max(skill);
    best = find(skill==maxSkill, 1);
    
    % Record the sensor and its explained variance
    expVar(s) = skill(best);
    bestSite(s) = sites(best);
    
    % Get the Kalman gain for the optimal sensor
    Ybest = Ydev(best, :);
    Rbest = Rs(best);
    
    Knum = unbias .* (Xdev * Ybest');
    Kdenom = unbias .* (Ybest * Ybest') + Rbest;
    K = Knum / Kdenom;
    a = 1 / (1 + sqrt(Rbest/Kdenom));
    
    % Update the ensemble deviations and sensor array.
    Xdev = Xdev - a * K * Ybest;
    use(sites(best)) = false;
    
    % Update the estimates if not using PSMs
    if ~obj.hasPSMs
        Knum = unbias .* (Ydev * Ybest');
        K = Knum / Kdenom;
        Ydev = Ydev - a * K * Ybest;
    end 
end

end