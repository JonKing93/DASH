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
        
        nState;
        nEns;
        nObs;
        nTime;
    end
    
    % Constructor
    methods
        function obj = dash2(M, D, R, F)
            
            % Create the default settings structure
            obj.settings = struct('ensrf', [], 'particleFilter', [], 'optimalSensor', []);
            obj.settings.ensrf = struct( 'type', 'joint', 'localize', [], 'inflate', 1, 'append', false, 'meanOnly', false );
            obj.settings.particleFilter = struct('type', "weight", 'N', NaN, 'big', false, 'nEns', NaN);
            obj.settings.optimalSensor = struct('replace', true, 'nSensor', 1, 'sites', [], 'radius', 0 );
            
        end
    end
    
    % Settings for different types of analyses
    methods
        ensrfSettings( obj, varargin );
        pfSettings( obj, varargin );
        sensorSettings( obj, varargin );
    end
    
    % User methods to begin analyses
    methods
        optimalSensor;
        particleFilter;
        ensrf;
    end
    
    
    
    % User methods
    methods (Static)
        
        % Specifies to use localization
        localize;
        
        % Specifies to inflate
        inflate;
        
        % Uses an ensemble square root Kalman filter
        ensrf;
        
        % Uses a particle filter
        particleFilter;
        
        % Applies a particle filter to a data set too large to fit into
        % active memory
        bigParticleFilter;
        
        % Tests for optimal sensor placement
        optimalSensor;
    end
    
    % Internal methods
    methods
        
        % Actually applies inflation
        inflateEnsemble;
        
        % Computes localization weights
        [w, yloc] = covLocalization;
        
        % Breaks apart an ensemble, get mean/deviations/variance
        decomposeEnsemble;
        
        % 
    end
        
        
        
        
    
        
end
        
        