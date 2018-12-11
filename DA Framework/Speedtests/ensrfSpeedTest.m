% Load some test data
exptDriver;
clearvars -except crn R H T

% Get a time index for obs
tdex = 1000;

% Restrict everything to actual observations
currentObs = ~isnan( crn(:,tdex) );

D = crn( currentObs, tdex);
Rtest = R( currentObs, tdex);
Htest = H(currentObs,:);

% Test the serial and vectorized outputs for 1 update
tic
A1 = ensrfSerialUpdate(T, D, Rtest, Htest);
serialTime = toc;

tic
A2 = ensrfUpdate( T, D, Rtest, Htest);
vectorTime = toc;

fprintf( sprintf('Running in serial takes:  %f seconds\n', serialTime) );
fprintf( sprintf('Running vectorized takes: %f seconds\n', vectorTime) )

% Check that the two methods calculated that same value
figure
imagesc( abs(A1 - A2) );
colorbar;
title('Absolute differences between serial and vectorized calculations');