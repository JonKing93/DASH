function[output] = optimalSensor( M, Fj, R, N, replace, radius )
% Conducts an optimal sensor test
%
% output = dash.sensorTest( J, M, sites, N )
% Finds the N best sensors.
%
% output = dash.sensorTest( J, M, sites, N, replace )
% Specify whether to replace or remove sites from consideration after being
% selected. Default is with replacement
%
% output = dash.sensorTest( J, M, sites, N, replace, radius )
% Specify to remove sites within a given radius after a nearby site is
% selected. Default is no radius.
%
% ----- Inputs -----
%
% J: A metric vector. (1 x nEns)
%
% M: A model ensemble (nState x nEns)
%
% sites: A sensorSites object
%
% N: The number of sensors to test. A positive integer.
%
% replace: Whether to replace sensors after selection. A scalar logical.
%          Default is true.
%
% radius: The radius in which to remove sites after a nearby site is
%         selected. Default is no radius.
%
% ----- Outputs -----
%
% output: A structure with the following fields
%
%   settings - Settings used to run the analysis
%
%   bestH - The state vector indices of the best sites
%
%   bestSite - The index of the best site in the sensorSites object.
%
%   skill - The relative reduction in J variance of each placement.

% Preallocate
bestH = NaN( N, 1 );
bestSite = NaN( N, 1 );
skill = NaN( N, 1 );

% Decompose
[Mmean, Mdev] = dash.decompose(M);

% For each new sensor, get the metric J
progressbar(0)
for s = 1:N
    Mj = Mmean(Fj.H) + Mdev(Fj.H,:);
    J = dash.processYeR( Fj, Mj, 1, NaN, NaN );    
    [~, Jdev] = dash.decompose(J);
    
    % Test the skill of each site remaining for consideration
    checkSites = find( sites.useSite );
    expVar = sensorTest.assessPlacement( Jdev, Mdev, sites.H(checkSites), sites.R(checkSites) );
    
    % Find the best site.
    currBest = find( expVar == max(expVar), 1 );
    bestSite(s) = checkSites( currBest );
    bestH(s) = sites.H( bestSite(s) );
    skill(s) = expVar( currBest );
    
    % Optionally remove the site and sites within the radius. Stop the loop
    % if no sites are left
    sites = sites.removeRadius( curr, radius );
    if ~replace
        sites = sites.removeSite( curr );
    end
    if isempty(sites.H)
        progressbar(1);
        break;
    end
    
    % Update the ensemble
    [K, a] = kalmanFilter.serialKalman( Mdev, Mdev(sites.H(curr),:), ones(size(Mmean)), sites.R(curr) );
    Mmean = Mmean + K * Mdev(H,:);
    Mdev = Mdev - a * K * Mdev(H,:);
    M = Mmean + Mdev;
    
    progressbar(s/N);
end

% Remove any extra entries if quitting early
best(isnan(best)) = [];
skill(isnan(skill)) = [];

% Get the output structure
output.settings = struct('Analysis', 'Optimal Sensor', 'N', N, 'Replacement', replace );
if ~isnan(radius)
    output.settings.Radius = radius;
end
output.bestH = bestH;
output.bestSite = bestSite;
output.skill = skill;

end    