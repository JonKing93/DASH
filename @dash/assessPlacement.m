function[skill] = assessPlacement( Jdev, Mdev, H, R )
% Assesses the utility of sensor placements relative to a metric.
%
% skill = dash.assessPlacement( Jdev, Mdev, H, R )
%
% ----- Inputs -----
%
% Jdev: The ensemble deviations of the metric
%
% Mdev: The ensemble deviations of the prior
%
% H: The state vector indices of the sites to test
%
% R: The uncertainty associated with a measurement at each site
%
% ----- Outputs -----
%
% skill: The relative change in variance in J explained by the sensor

% Preallocate
nSite = numel(H);
skill = NaN( nSite, 1 );

% Variance of the metric
Jvar = var(Jdev,[],2);

% Get the model deviations for each site. Use to compute the change in the
% variance of J
for s = 1:nSite
    HMdev = Mdev(sites(s),:);
    
    covJH = cov( Jdev', HMdev' );
    dStdJ = covJH(2).^2 / ( var(HMdev,[],2) + R(s) );
    skill(s) = dStdJ ./ Jvar;
end

end