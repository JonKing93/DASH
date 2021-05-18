function[out] = run2(obj, N)
%% Runs an optimal sensor test for the best N sensors.
%
% out = obj.run(N)
%
% ----- Inputs -----
%
% N: How many optimal sensors to find. A scalar positive integer.
%
% ----- Outputs -----
%
% out: A structure containing output quantities

% Check for essential fields
assert(~isempty(obj.X), 'You must specify a prior before you run an optimal sensor test');
assert(obj.hasPSMs || ~isempty(obj.Ye), 'You must provide either PSMs or estimates before running an optimal sensor test');
assert(~isempty(obj.metricType), 'You must specify a metric before running an optimal sensor test.');

% Error check
dash.assertScalarType(N, 'N', 'numeric', 'numeric');
dash.assertPositiveIntegers(N, 'N', false, false);
assert(N<=obj.nSite, sprintf('N cannot be larger than the number of sensor sites (%.f)', obj.nSite));

% Preallocate the output structure
out = obj.preallocateOutput(N);

% Initialize the sensor test
X = obj.X;
R = obj.R;
unbias = 1 / (obj.nEns - 1);
sites = (1:obj.nSite)';

% Initialize metric
J = obj.computeMetric(X);
[~, Jdev] = dash.decompose(J);

% Initialize estimate deviations
if obj.hasPSMs
    obj.Ye = PSM.computeEstimates(X, obj.F);
    checkPSMOutput;
end
[~, Ydev] = dash.decompose(obj.Ye);

% Record initial value output
if os.return_metric.initial
    out.metric.initial = J;
end

% For each new sensor, get the relative change in variance for each site
for s = 1:N
    Yvar = unbias * sum(Ydev.^2, 2);
    deltaVar = (unbias * Ydev * Jdev').^2 ./ (Yvar + R);

    % Rank each site by ability to reduce variance
    [~, sortIndex] = sort(deltaVar, 'descend');
    [~, rank] = ismember(1:numel(sites), sortIndex);
    
    % Get the best site and associated values
    best = sortIndex(1);
    Ybest = Ydev(best,:);
    Rbest = R(best);
    bestSite = sites(best);
    
    % Update the ensemble deviations using the best site
    [Xmean, Xdev] = dash.decompose(X);
    Knum = unbias .* (Xdev * Ybest');
    Kdenom = unbias .* (Ybest * Ybest') + Rbest;
    K = Knum / Kdenom;
    a = 1 / (1+sqrt(Rbest/Kdenom));
    Xdev = Xdev - a * K * Ybest;
    X = Xmean + Xdev;
    
    % Update the new metric
    J = obj.computeMetric(X);
    [~, Jdev] = dash.decompose(J);
    
    % Remove the best site from future consideration
    sites(best) = [];
    R(best) = [];
    if obj.hasPSMs
        obj.F(best) = [];
    else
        Ydev(best,:) = [];
    end
    
    % Update PSM estimates
    if obj.hasPSMs
        Ye = PSM.computeEstimates(X, obj.F);
        checkPSMOutput;
        [~, Ydev] = dash.decompose(Ye);
        
    % Or update estimates directly
    else
        Knum = unbias .* (Ydev * Ybest');
        K = Knum / Kdenom;
        Ydev = Ydev - a * K * Ybest;
    end
    
    % Record output
    allSites = [bestSite; sites];
    out.best(s) = bestSite;
    out.rank(allSites, s) = rank;
    out.expVar.best(s) = deltaVar(best);
    out.expVar.potential(allSites,s) = deltaVar;
    if os.return_metric.updated
        out.metric.updated(s,:) = J;
    end
end

% Record final output values
if os.return_metric.final
    out.metric.final = J;
end

end

        
        
        
        
        


% % 
% % 
% % % Initialize
% % X = obj.X;
% % if obj.hasPSMs
% %     obj.Ye = PSM.computeEstimates(X, obj.F);
% %     checkPSMOutput;
% % end
% % [~, Ydev] = dash.decompose(obj.Ye);
% % 
% % 
% % 
% % 
% % % Initialize
% % R = obj.R;
% % sites = 1:obj.nSite;
% % unbias = 1/(obj.nEns-1);
% % 
% % [Xmean, Xdev] = dash.decompose(obj.X);
% % if ~obj.hasPSMs
% %     [~, Ydev] = dash.decompose(obj.Ye);
% % end
% % 
% % % Get the updated ensemble for each new sensor
% % for s = 1:N
% %     X = Xmean + Xdev;
% % 
% %     % If running PSMs, generate new estimate deviations
% %     if obj.hasPSMs
% %         Ye = PSM.computeEstimates(X, obj.F);
% %         checkPSMOutput;
% %         [~, Ydev] = dash.decompose(Ye);
% %     end
% % 
% %     % Get the variance of the deviations and the metric
% %     Yvar = unbias * sum(Ydev.^2, 2);
% %     J = obj.computeMetric(X);
% %     [~, Jdev] = dash.decompose(J);
% %     Jvar = unbias * sum(Jdev.^2, 2);
% %     
% %     % Get the relative change in variance for each sensor. Rank the sensors
% %     % by their ability to reduce variance.
% %     deltaVar = (unbias * Ydev * Jdev').^2 ./ (Yvar + R);
% %     [~, sortIndex] = sort(deltaVar, 'descend');
% %     [~, rank] = ismember(1:numel(sites), sortIndex);
% %     
% %     % Extract the best site
% %     best = sortIndex(1);
% %     Ybest = Ydev(best,:);
% %     Rbest = R(best);
% %     
% %     % Update the ensemble deviations using the best site
% %     Knum = unbias .* (Xdev * Ybest');
% %     Kdenom = unbias .* (Ybest * Ybest') + Rbest;
% %     K = Knum / Kdenom;
% %     a = 1 / (1+sqrt(Rbest/Kdenom));
% %     Xdev = Xdev - a * K * Ybest;    
% %     
% %     % Save
% %     out.best(s) = sites(best);
% %     out.rank(sites, s) = rank;
% %     if os.return_metric.intial && s==1
% %         out.metric.initial = J;
% %     
% %     
% %     
% %     
% %     
% %     
% %     
% %     
% %     
% %     
% %     best = find(deltaVar==maxSkill, 1);
% %     
% %     % Update the ensemble deviations using the best site
% %     Knum = unbias .* (Xdev * Ybest');
% %     Kdenom = unbias .* (Ybest * Ybest') + Rbest;
% %     K = Knum / Kdenom;
% %     a = 1 / (1+sqrt(Rbest/Kdenom));
% %     Xdev = Xdev - a * K * Ybest;
% %     
% %     % Update estimate deviations if not using PSMs
% %     if ~obj.hasPSMs
% %         Knum = unbias .* (Ydev * Ybest');
% %         K = Knum / Kdenom;
% %         Ydev = Ydev - a * K * Ybest;
% %     end
% %     
% %     % Record output
% %     out.best(s) = sites(best);
% %     out.rank(sites, s) = 
% % 
