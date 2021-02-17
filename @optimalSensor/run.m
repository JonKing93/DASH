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

% Locate any R values that need to be filled by the PSM
fill = isnan(obj.R);

% Get the estimates, their deviations, and variance
for s = 1:N
    if obj.hasPSMs
        [obj.Ye, Rpsm] = PSM.estimate(obj.X, obj.F);
        obj.R(fill) = Rpsm(fill);
    end
    Ydev = dash.decompose(obj.Ye);
    Yvar = unbias * sum(Ydev.^2, 2);
    
    % Get the deviations and variance of the metric/index
    Jdev = obj.computeMetric(obj.X);
    Jvar = unbias * sum(Jdev.^2, 2);
    
    % Get the relative change in variance caused by each sensor
    skill = ((unbias .* Ydev * Jdev') ./ (Yvar + R)) ./ Jvar;
    
    % The optimal sensor maximizes the change in variance
    expVar(s) = max(skill);
    best = find(skill==expVar(s), 1);
    bestSite(s) = testSites(best);
    
    % Update the ensemble using the optimal sensor
    

