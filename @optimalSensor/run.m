function[bestSites, expVar] = run(obj, N)
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
bestSites = NaN(N, 1);
expVar = NaN(N, 1);
fill = isnan(obj.R);

% Initialize
R = obj.R;
[Xmean, Xdev] = dash.decompose(obj.X);
sites = 1:obj.nSite;

if ~obj.hasPSMs
    [~, Ydev] = dash.decompose(obj.Ye);
end

% Unbiased estimator for statistical calculations
unbias = 1/(obj.nEns-1);

% Get the updated ensemble for each new sensor
for s = 1:N
    X = Xmean + Xdev;
    
    % If running PSMs, generate the new estimate deviations
    if obj.hasPSMs
        X = Xmean + Xdev;
        Ye = PSM.computeEstimates(X, obj.F);
        checkPSMOutput;
        [~, Ydev] = dash.decompose(Ye);
    end
    
    % Get the variance of the deviations and the metric
    Yvar = unbias * sum(Ydev.^2, 2);
    J = obj.computeMetric(X);
    [~, Jdev] = dash.decompose(J);
    Jvar = unbias * sum(Jdev.^2, 2);
    
    % Get the relative change in variance caused by each sensor. The
    % optimal sensor maximizes the change in variance
    deltaVar = (unbias * Ydev * Jdev).^2 ./ (Yvar + R);
    maxSkill = max(deltaVar);
    best = find(deltaVar==maxSkill, 1);
    
    % Record the sensor and its explained variance
    bestSites(s) = sites(best);
    expVar(s) = maxSkill/Jvar;
    
    % Extract the best site from the sensor array
    Ybest = Ydev(best,:);
    Rbest = R(best);
    
    sites(best) = [];
    Ydev(best,:) = [];
    fill(best) = [];
    R(best) = [];
    if obj.hasPSMs
        obj.F(best) = [];
    end
    
    % Update the ensemble deviations using the best site
    Knum = unbias .* (Xdev * Ybest');
    Kdenom = unbias .* (Ybest * Ybest') + Rbest;
    K = Knum / Kdenom;
    a = 1 / (1+sqrt(Rbest/Kdenom));
    Xdev = Xdev - a * K * Ybest;
    
    % Update the estimate deviations if not using PSMs
    if ~obj.hasPSMs
        Knum = unbias .* (Ydev * Ybest');
        K = Knum / Kdenom;
        Ydev = Ydev - a * K * Ybest;
    end
end

end