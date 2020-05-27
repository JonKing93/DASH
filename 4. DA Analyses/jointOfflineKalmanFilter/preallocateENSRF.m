function[output, calculateMean, calculateDevs] = preallocateENSRF( nObs, ...
          nTime, nState, nEns, nPercs, nCalcs, returnMean, returnVar, returnDevs )
%% Preallocates output for the filter. Determines whether to update
% ensemble means and deviations based on required output.

% Initialize structure
output = struct;

% Record which calculations are necessary
calculateMean = false;
calculateDevs = false;

% Calibration ratio
output.calibRatio = NaN(nObs, nTime);

% Ensemble mean
if returnMean
    output.Amean = NaN(nState, nTime);
    calculateMean = true;
end

% Ensemble variance
if returnVar
    output.Avar = NaN(nState, nTime);
    calculateDevs = true;
end

% Ensemble deviations
if returnDevs
    output.Adev = NaN( nState, nEns, nTime );
    calculateDevs = true;
end

% Ensemble percentiles
if nPercs > 0
    output.Aperc = NaN( nState, nPercs, nTime );
    calculateMean = true;
    calculateDevs = true;
end

% Posterior calculations
if nCalcs > 0
    output.calcs = NaN( nCalcs, 2, nTime );
    calculateMean = true;
    calculateDevs = true;
end

end
    


    