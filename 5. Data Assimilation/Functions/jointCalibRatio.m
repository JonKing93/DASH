function[cr, Ropt, Ymean, Yvar, R] = jointCalibRatio( M, D, R, F, inflate )
%% Calculates the calibration ratio for joint updates without running a full assimilation.
%
% [cr, Ropt, Ymean, Yvar, R] = jointCalibRatio( M, D, R, F )
%
% [cr, Ropt, Ymean, Yvar, R] = jointCalibRatio( M, D, R, F, inflate )

% Use a default inflation factor if unspecified
if ~exist( 'inflate', 'var' )
    inflate = 1;
end

% Error checking
% errCheck( M, D, R, F, inflate );

% Apply the inflation factor
M = inflateEnsemble( inflate, M );

% Get some sizes
[nObs, nTime] = size(D);

% Preallocate the calibration ratio, Y mean, Y variance
cr = NaN( nObs, nTime );
Ymean = NaN( nObs, 1 );
Yvar = NaN( nObs, 1 );

% For each observation
for d = 1:nObs
    
    % Initialize a logical update array
    update = false( 1, nTime );
    
    % Get the model values to pass
    Mpsm = M( F{d}.H, : );
    
    % Get the time steps with observations
    hasObs = ~isnan( D(d,:) );
    
    % Run the PSM
    [Ye, R(d,hasObs), update(hasObs)] = getPSMOutput( F{d}, Mpsm, R(d,hasObs), NaN, d  );
    
    % Get the mean and variance of the Ye
    [Ymean(d), ~, Yvar(d)] = decomposeEnsemble( Ye );
    
    % Get the calibration ratio
    cr(d, update) = ( D(d,update) - Ymean(d) ) ./ ( Yvar(d) + R(d,update) );
end

% Get the optimal R
Ropt = calibrateR(D, Ymean, Yvar);
   
end