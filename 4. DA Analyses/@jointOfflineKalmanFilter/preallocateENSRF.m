function[output, calculateMean, calculateDevs] = preallocateENSRF( nObs, ...
          nTime, nState, nEns, returnMean, returnVar, percentiles, returnDevs )
%% Preallocates output for the filter. Determines whether to update
% ensemble means and deviations based on required output.

% Initialize structure
output = struct;

% REcord which calculations are necessary
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

% Ensemble percentiles
if ~isempty(percentiles)
    nPerc = numel(percentiles);
    output.Aperc = NaN( nState, nPerc, nTime );
    calculateMean = true;
    calculateDevs = true;
end

% Ensemble deviations
if returnDevs
    output.Adev = NaN( nState, nEns, nTime );
    calculateDevs = true;
end

end
    


    