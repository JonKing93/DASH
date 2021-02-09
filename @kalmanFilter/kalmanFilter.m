classdef kalmanFilter < ensembleFilter
    %% Implements a Kalman Filter analysis using an ensemble square root Kalman Filter
    %
    % kalmanFilter Methods:
    %   kalmanFilter - Creates a new kalmanFilter object
    %   
    %   observations - Sets the proxy observations and uncertainties
    %   prior - Sets the prior ensemble
    %   estimates - Sets the proxy estimates
    %
    %   variance - Enable or disable posterior ensemble variance as output
    %   percentiles - Return posterior ensemble percentiles as output
    %   deviations - Return posterior ensemble percentiles as output
    %   index - Returns the posterior for an index as output
    %   mean - Enable or disable the ensemble mean as output
    %
    %   localize - Implement covariance localization
    %   blend - Implement covariance blending
    %   inflate - Apply covariance inflation
    %   setCovariance - Specify covariance estimates directly
    %   resetCovariance - Restore covariance options to defaults
    %   covarianceEstimate - Return the covariance estimate for a given assimilated time step
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = private)
        %% Covariance adjustments
        
        % Inflation
        inflateCov = false; % True or false toggle
        inflateFactor; % Inflation factor
        whichFactor; % Which factor to use in each time step
        
        % Localization
        localizeCov = false; % Logical toggle
        wloc; % State vector localization weights
        yloc; % Y Localization weights
        whichLoc; % Which localization to use in each time step
        
        % Blending
        setCov = false; % Toggle for setting C directly
        blendCov = false; % Toggle for blending C
        C; % State vector-proxy covariance matrix
        Ycov; % Y covariance matrix
        whichCov; % Which covariance to use in each time step
        blendWeights; % Blending weights
        
        %% Output options
        
        % Basic returns
        return_mean; % Whether to return the posterior mean
        return_devs; % Whether to return the posterior deviations
        
        % Posterior calculations
        Q = cell(0,1); % Posterior calculations
        Qname = strings(0,1); % The output name of each posterior calculation
        
        % Saving to file
        file; % Save file
        overwrite; % Overwrite permission
    end
        
    % Constructor
    methods
        function[kf] = kalmanFilter(name)
            %% Creates a new kalmanFilter object
            %
            % kf = kalmanFilter;
            % Creates a new kalman filter
            %
            % kf = kalmanFilter(name)
            % Optionally gives the kalman filter an identifying name.
            %
            % ----- Inputs -----
            %
            % name: An optional name for the Kalman filter. A string.
            %
            % ----- Outputs -----
            %
            % kf: The new kalman filter object
            
            % Name            
            if ~exist('name','var') || isempty(name)
                name = "";
            end
            kf = kf.rename(name);
            
            % Return mean and variance by default
            kf.return_mean = true;
            kf.return_devs = false;
            kf = kf.variance(true);
        end
    end
    
    % ensembleFilter methods
    methods
        kf = prior(kf, M, whichPrior);
        kf = observations(kf, D, R);
        out = run(kf);
    end

    % User output options
    methods
        kf = mean(kf, tf);
        kf = deviations(kf, tf);
        kf = percentiles(kf, percs);
        kf = variance(kf, tf);
        kf = index(kf, name, weights, rows);
    end
    
    % User covariance methods
    methods
        kf = inflate(kf, factor, whichFactor);
        kf = localize(kf, wloc, yloc, whichLoc);
        kf = blend(kf, C, Ycov, weights, whichCov);
        kf = setCovariance(kf, C, Ycov, whichCov);
        kf = resetCovariance(kf);
        [C, Ycov] = covarianceEstimate(kf, t);
    end
    
    % Utilities
    methods
        checkSize(kf, siz, type, dim, inputName);
        assertEditableCovariance(kf, type);
        [whichCov, nCov] = checkCovariance(kf, C, Ycov, whichCov, locInputs);
        kf = finalize(kf, actionName);
        [Knum, Ycov] = estimateCovariance(kf, t, Mdev, Ydev);
    end    
    
end