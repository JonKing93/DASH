classdef kalmanFilter
    
    % Essentials
    properties
        % ID
        name;
        
        % Basic inputs
        M; % Priors
        D; % Observations
        R; % Observation uncertainties
        Y; % Estimates
        
        % Sizes
        nState;
        nEns;
        nPrior;
        nSite;
        nTime;
    end
        

        

    
    % Covariance modification
    properties        
        % Inflation
        inflateFactor; % Inflation factor
        
        % Localization
        w; % State vector localization weights
        yloc; % Y Localization weights
        whichLoc; % Which localization to use in each time step
        
        % Blending
        C; % State vector-proxy covariance matrix
        Ycov; % Y covariance matrix
        whichCov; % Which covariance to use in each time step
        setC; % true is C was set directly, false if blending
        weights; % Blending weights
        end       
    
    % Output options
    properties
        return_mean; % Whether to return the posterior mean
        
        
        
        file; % Save file
        overwrite; % Overwrite permission
        Q; % Calculators that require deviations
        returnDevs; % Whether to return deviations
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
            
            % Default
            if ~exist('name','var') || isempty(name)
                name = "";
            end
            
            % Check name and save
            kf.name = dash.assertStrFlag(name, 'name');
        end
    end                
        
    % User basic inputs
    methods
        kf = prior(kf, M, whichPrior);
        kf = observations(kf, D, R);
        kf = estimates(kf, Y);
    end
    
    % User covariance methods
    methods
        kf = setCovariance(kf, C, Ycov, whichCov);
        kf = blend(kf, C, Ycov, weights, whichCov);
        kf = inflate(kf, inflateFactor);
        kf = localize(kf, w, yloc, whichLoc);
    end
    
    % User output options
    methods
        percentiles;
        returnMean;
        returnVariance;
        returnDeviations;
    end
    
    % Utilities
    methods
        checkSize(kf, siz, type, dim, inputName);
        assertEditableCovariance(kf, type);
        [whichCov, nCov] = checkCovariance(kf, C, Ycov, whichCov, locInputs);
    end    
    methods (Static)
        [nDim1, nDim2, nDim3] = checkInput(X, name, allowNaN, requireMatrix);
    end
end