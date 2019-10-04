function[uk, R] = runForwardModel( obj, M, ~, ~ )
% Runs the UK forward model. Searches coordinate polygons for seasonal
% areas

% Get the appropriate season for the region
ind = obj.seasonalPolygon;
SST = mean( M(ind,:), 1 );

% Run the forward model, estimate R from the variance of the estimate
uk = ukPSM.UK_forward_model( SST, obj.bayesFile );
R = mean( var(uk,[],2), 1 );

uk = mean( uk, 2 )';
end


