function[skill] = assessPlacement( Jdev, HMdev, R )
% Assesses the utility of sensor placements relative to a metric.
%
% skill = dash.assessPlacement( Jdev, Mdev, R )
%
% ----- Inputs -----
%
% Jdev: The ensemble deviations of the metric
%
% Mdev: The ensemble deviations of the prior at the sensor sites
%
% R: The uncertainty associated with a measurement at each site
%
% ----- Outputs -----
%
% skill: The relative change in variance in J explained by the sensor

% Preallocate
nSite = size(HMdev,1);
skill = NaN( nSite, 1 );

% Variance of the metric
Jvar = var(Jdev,[],2);

% Get the model deviations for each site. Use to compute the change in the
% variance of J
for s = 1:nSite
    covJH = cov( Jdev', HMdev(s,:)' );
    dStdJ = covJH(2).^2 / ( var(HMdev(s,:),[],2) + R(s) );
    skill(s) = dStdJ ./ Jvar;
end

end