classdef kalmanFilter
    
    properties
        % Basic inputs
        X; % Priors
        D; % Observations
        R; % Observation uncertainties
        Y; % Estimates
        
        % Covariance settings
        C; % Covariance matrix for blending
        Ycov; % Y covariance for blending
        weights; % How much to weight the covariance from the prior and the blended covariance
        inflateFactor; % Inflation factor
        w; % Localization weights
        yloc; % Y Localization weights
        
        % Output options
        file; % Save file
        overwrite; % Overwrite permission
        Q; % Calculators that require deviations
        returnDevs; % Whether to return deviations
        
        % Sizes
        nState;
        nEns;
        nPrior;
        nSite;
        nTime;
    end
    
    % User basic inputs
    methods
        prior;
        observations;
        estimates;
    end
    
    % User covariance methods
    methods
        setCovariance;
        blend;
        inflate;
        localize;
    end
    
    % User output options
    methods
        percentiles;
        returnVariance;
        returnDeviations;
    end
end