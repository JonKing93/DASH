classdef kalmanFilter
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
        % ID
        name;
        
        % Basic inputs
        M; % Priors
        whichPrior; % Which prior to use in each time step
        D; % Observations
        R; % Observation uncertainties
        Y; % Estimates
        
        % Sizes
        nState = 0;
        nEns = 0;
        nPrior = 0;
        nSite = 0;
        nTime = 0;
    
        %% Covariance adjustments
        
        % Inflation
        inflateCov = false; % True or false toggle
        inflateFactor; % Inflation factor
        
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
            
            % Default name
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
        
    % User basic inputs
    methods
        kf = rename(kf, newName);
        kf = prior(kf, M, whichPrior);
        kf = observations(kf, D, R);
        kf = estimates(kf, Y);
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
        kf = localize(kf, w, yloc, whichLoc);
        kf = blend(kf, C, Ycov, weights, whichCov);
        kf = inflate(kf, inflateFactor);
        kf = setCovariance(kf, C, Ycov, whichCov);
        kf = resetCovariance(kf);
        kf = covarianceEstimate(t);
        
        
        [Knum, Ycov] = estimateCovariance(kf, t, Mdev, Ydev);
    end
    
    % Static Ensrf analysis methods
    methods (Static)
        [Mmean, Mdev] = decompose(M, dim);
    end
    
    % Utilities
    methods
        checkSize(kf, siz, type, dim, inputName);
        assertEditableCovariance(kf, type);
        [whichCov, nCov] = checkCovariance(kf, C, Ycov, whichCov, locInputs);
        settings = covarianceSettings(kf);
    end    
    methods (Static)
        [nDim1, nDim2, nDim3] = checkInput(X, name, allowNaN, requireMatrix);
    end
    
end