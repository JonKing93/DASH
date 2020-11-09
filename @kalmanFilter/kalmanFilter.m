classdef kalmanFilter
    
    properties
        % ID
        name;
        
        % Basic inputs
        X; % Priors
        D; % Observations
        R; % Observation uncertainties
        Y; % Estimates
        
        % Covariance settings
        C; % Covariance matrix
        Ycov; % Y covariance matrix
        setC; % Whether C is set (true), or for blending (false)
        weights; % How much to weight the covariance from the prior and the blended covariance
        whichCov; % Which covariance to blend in each time step
        inflateFactor; % Inflation factor
        w; % Localization weights
        yloc; % Y Localization weights
        whichLoc;
        
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