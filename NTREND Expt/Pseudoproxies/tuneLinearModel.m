function[linModel] = tuneLinearModel( linReg, Ttrue, Tghcn )

% Get the mean of the GHCN temperatures
gMean = nanmean( Tghcn, 2);

% Get the mean of the truth run
tMean = mean( Ttrue, 2);

% Adjust the intercept. ( gProxy = a1 + B*gMean,  tProxy = a2 + B*tMean.
% We want gProxy = tProxy (at least for the mean) so...
% a2 = a1 + B*(gMean - tMean)
intercept = linReg(:,1) + linReg(:,2) .* (gMean - tMean);

% Create the linear model
linModel = [intercept, linReg(:,2)];

end