function[out] = run(obj, N)
%% Runs an optimal sensor test for the best N sensors.
%
% out = obj.run
% Finds the optimal sensor in the network
%
% out = obj.run(N)
% Finds the N sequential optimal sensors
%
% out = obj.run('all')
% Iterates through every sensor in the network.
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

% Default and parse N
if ~exist('N','var') || isempty(N)
    N = 1;
elseif dash.string.isflag(N) && strcmpi(N, 'all')
    N = obj.nSite;
end

% Error check
dash.assert.scalarType(N, 'N', 'numeric', 'numeric');
dash.assert.positiveIntegers(N, 'N', false, false);
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
Jvar = unbias * sum(Jdev.^2, 2);

% Initialize estimate deviations
if obj.hasPSMs
    obj.Ye = PSM.estimate.compute(X, obj.F);
    checkPSMOutput;
end
[Ymean, Ydev] = dash.decompose(obj.Ye);

% Record initial value output
out.metric.initial = J;
out.metricVar.initial = Jvar;

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
    Jvar = unbias * sum(Jdev.^2, 2);

    % Record output
    out.best(s) = bestSite;
    out.rank(sites, s) = rank;
    out.expVar.best(s) = deltaVar(best);
    out.expVar.potential(sites,s) = deltaVar;
    out.metricVar.updated(s) = Jvar;

%     out.posterior.updated(:,:,s) = X;
%     out.metric.updates(s,:) = J;

    
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
        Ye = PSM.estimate.compute(X, obj.F);
        checkPSMOutput;
        [Ymean, Ydev] = dash.decompose(Ye);
        
    % Or update estimates directly
    else
        Knum = unbias .* (Ydev * Ybest');
        K = Knum / Kdenom;
        Ydev = Ydev - a * K * Ybest;
    end
    
    % Optionally output PSM updates
%     !! Double check this before using
%     out.estimates.updated(sites,:,s) = Ymean + Ydev;
end

% Record final output values
out.metricVar.final = Jvar;
out.metric.final = J;

% Compute percent explained variances
out.percentVar.best = 100 * out.expVar.best / out.metricVar.initial;
out.percentVar.potential = 100 * out.expVar.potential / out.metricVar.initial;

remVar = [out.metricVar.initial, out.metricVar.updated(1:end-1)];
out.percRemVar.best = 100 * out.expVar.best ./ remVar;
out.percRemVar.potential = 100 * out.expVar.potential ./ remVar;




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
