classdef dash < handle
    % dash
    % Implements data assimilation. Provides error checking and
    % implementation of offline ensemble Kalman Filters, Particle Filters, 
    % and optimal sensor analyses.
    %
    % *** Note: All methods used in data assimilation are static, thus may
    % be used as standalone functions. However, the individual functions
    % provide minimal error-checking, so use at your own risk.
    %
    % dash Methods:
    %   dash - Creates a new data assimilation analysis object.
    %   setValues - Change the model prior, observations, uncertainty, or PSMs
    %
    %   ensrf - Run an offline, ensemble kalman filter assimilation
    %   ensrfSettings - Change the settings used for an ensemble kalman filter
    %
    %   particleFilter - Run a particle filter assimilation
    %   pfSettings - Change the settings used for a particle filter
    %
    %   optimalSensor - Test for optimal sensor placements
    %   sensorSettings - Change the settings used for optimal sensors
    %
    %   localizationWeights - Computes distance based localization weights
    %   regrid - Converts a state vector or a matrix of state vectors to a gridded data array.
    %   regridTripolar - Converts a tripolar state vector or matrix of state vectors to a gridded data array.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    properties (SetAccess = private)
        settings;   % Instructions for different types of DA
        
        M;      % An ensemble. Either an ensemble object or (nState x nEns) matrix
        D;      % Observations. 
        R;      % Observation uncertainty.
        F;      % Forward operators
        
        Rtype   % Records whether input R was a scalar, vector, or matrix
        
        nState;  % Number of state elements
        nEns;    % Number of ensemble members
        nObs;    % Number of observations
        nTime;   % Number of time steps
    end
    
    % Constructor
    methods
        function obj = dash2(M, D, R, F)
            
            % Create the default settings structure
            obj.settings = struct('ensrf', [], 'particleFilter', [], 'optimalSensor', []);
            obj.settings.ensrf = struct( 'type', 'joint', 'localize', [], 'inflate', 1, 'append', false, 'meanOnly', false );
            obj.settings.particleFilter = struct('type', "weight", 'N', NaN, 'big', false, 'nEns', NaN);
            obj.settings.optimalSensor = struct('replace', true, 'nSensor', 1, 'radius', NaN );
            
            obj.setValues( M, D, R, F );
        end
    end
    
    % Settings for analyses.
    methods
        
        % Kalman filter settings
        ensrfSettings( obj, varargin );
        
        % Particle filter settings
        pfSettings( obj, varargin );
        
        % Optimal sensor settings
        sensorSettings( obj, varargin );
        
        % Set values of variables used for DA
        setValues( obj, M, D, R, F, S );
        
    end
    
    % User methods to initiate analysis
    methods
        
        % Do an optimal sensor analysis
        output = optimalSensor( obj, J, sites )
        
        % Run a particle filter
        output = particleFilter( obj );
        
        % Run an Ensemble Kalman Filter data assimilation
        output = ensrf( obj );
          
    end
    
    % Regridding
    methods (Static)
        
        % Regrids a variable in an ensemble from a state vector.
        [A, meta, dimID] = regrid( A, var, ensMeta, keepSingleton )
        
        % Regrids a tripolar variable
        [rA, dimID] = regridTripolar( A, var, ensMeta, gridSize, notnan, keepSingleton );
        
    end
    
    % General analysis methods
    methods (Static)
        
        % Inflates the covariance matrix
        M = inflate( M, factor );
        
        % Breaks an ensemble into mean and devations. Also variance.
        [Mmean, Mdev, Mvar] = decompose( M );
        
        % Calculate localization weights
        [weights, yloc] = localizationWeights( siteCoord, stateCoord, R, scale);
        
        % Error check Ye and R generation on the fly without crashing the analysis
        [Ye, R, use] = processYeR( F, Mpsm, R, t, d );
        
    end        
        
    % Ensrf analysis methods
    methods (Static)
        
        % Implements joint updates
        jointENSRF;
        
        % Efficiently computes Kalman gain for joint updates
        varargout = jointKalman( type, varargin );
        
        % Implements serial updates
        serialENSRF;
        
        % Efficiently computes Kalman gain for serial updates
        [K, a] = serialKalman( Mdev, Ydev, w, R );
        
        % Appends Ye, gets trivial PSMs
        [M, F] = appendYe( M, F );
        
        % Unappends Ye from ensemble
        [M, Ye] = unappendYe( M );      

    end
    
    % Particle filter methods
    methods (Static)
        
        % Normal particle filter
        output = pf( M, D, R, F, N );
        
        % Particle filter for large ensembles
        output = bigpf( ens, D, R, F, N, batchSize )
        
        % Compute particle weights
        weights = pfWeights( sse, N );
        
        % Probabilistic weights
        Y = normexp( X, dim, nanflag );
        
    end
    
    % Optimal sensor methods
    methods (Static)
        
        % Assess skill of sites
        skill = assessPlacement( Jdev, Mdev, H, R );
        
        % Update the variance field
        Mdev = updateSensor( Mdev, H, R );
        
        % Run a sensor test
        output = sensorTest( J, M, sites, N, replace, radius )
        
    end
    
    
end