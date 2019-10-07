classdef dash2 < handle
    % Implements data assimilation
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    properties (SetAccess = private)
        settings;   % Instructions for different types of DA
        
        M;      % An ensemble. Either an ensemble object or (nState x nEns) matrix
        D;      % Observations. 
        R;      % Observation uncertainty.
        F;      % Forward operators
        
        Rtype   % Records
    end
    
    % Constructor (unfinished!)
    methods
        function obj = dash2(M, D, R, F, S)
            
            % Create the default settings structure
            obj.settings = struct('ensrf', [], 'particleFilter', [], 'optimalSensor', []);
            obj.settings.ensrf = struct( 'type', 'joint', 'localize', [], 'inflate', 1, 'append', false, 'meanOnly', false );
            obj.settings.particleFilter = struct('type', "weight", 'N', NaN, 'big', false, 'nEns', NaN);
            obj.settings.optimalSensor = struct('replace', true, 'nSensor', 1, 'sites', [], 'radius', 0 );
            
            obj.useValues( M, D, R, F, S )
        end
    end
    
    % Settings for different types of analyses.
    methods
        ensrfSettings( obj, varargin );
        pfSettings( obj, varargin );
        sensorSettings( obj, varargin );
        setValues( obj, M, D, R, F, S );
        localize( R, scale );
    end
    
    % User methods. Start analysis and regrid
    methods
        optimalSensor;
        particleFilter;
        
        % Runs an Ensemble Kalman Filter data assimilation
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
    
    
    
    
end