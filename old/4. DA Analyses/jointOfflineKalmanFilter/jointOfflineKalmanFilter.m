classdef jointOfflineKalmanFilter
    % Implements an offline, EnSRF Kalman Filter that updates all
    % observations simultaneously.
    
    
    properties
        % Kalman filter essentials
        M;     % Prior ensemble
        D;     % Observations
        R;     % Observation uncertainty
        Ye;    % Proxy estimates
        
        % Adjustments to covariance
        w;       % State vector localization weights
        yloc;    % Y localization weights
        inflate; % Inflation factor
        P;       % Pre-specified covariance matrix
        
        % Values calculated on the fly
        posteriorCalcs;   % Forward models that calculate values from the posterior.
        dynamicLocalizer; % Generates localization weights.
        
        % Types of output
        returnMean;
        returnVariance;
        returnDeviations;
        returnPercentiles;
    end
    
    methods
    end
    
end