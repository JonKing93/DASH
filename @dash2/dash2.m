classdef dash2 < handle
    % Implements data assimilation
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    properties
        settings;   % Instructions for different types of DA
        
        M;      % An ensemble. Either an ensemble object or (nState x nEns) matrix
        D;      % Observations. 
        R;      % Observation uncertainty.
        F;      % Forward operators
        
        nState;   % The number of state elements
        nEns;     % The number of ensemble members
        nObs;     % The number of observation sites
        nTime;    % The number of time steps
        nSensor;  % The number of sensor sites
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
    
    % Settings for different types of analyses. Also, error checking
    methods
        ensrfSettings( obj, varargin );
        pfSettings( obj, varargin );
        sensorSettings( obj, varargin );
        setValues( M, D, R, F, S );
    end
    
    % User methods to begin analyses
    methods
        optimalSensor;
        particleFilter;
        ensrf;
    end
    
    % General analysis methods
    methods (Static)
        
        % Inflates the covariance matrix
        M = inflate( M, factor );
        
        % Breaks an ensemble into mean and devations. Also variance.
        [Mmean, Mdev, Mvar] = decompose( M );
        
    end        
        
    % Ensrf analysis methods
    methods (Static)
        
        % Implements joint updates
        jointENSRF;
        
        % Implements serial updates
        serialENSRF;
        
        % Appends Ye, gets trivial PSMs
        [M, F] = appendYe( M, F );
        
        % Unappends Ye from ensemble
        [M, Ye] = unappendYe( M );      

    end
    
    
    
    
end