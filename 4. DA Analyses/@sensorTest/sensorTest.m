classdef sensorTest < dash
    % sensorTest
    % Implements tests for optimal sensor placement.
    %
    % sensorTest Methods:
    %   sensorTest - Creates a new sensor test object
    %   settings - Changes the settings for the sensor test
    %   run - Runs the test
    %   setValues - Changes the data used in an existing sensor test object

    properties (SetAccess = private)
        % Settings
        nSensor;  % The number of sensors to select
        replace;  % Whether to select sensors with or without replacement
        radius;  % Limits selection of new sensors outside of a distance radius
        
        % Analysis values
        M; % A model prior
        Fj; % A forward model used to estimate J from M 
        S;  % A sensorSites object.
    end
    
    % Constructor
    methods
        function obj = sensorTest( M, Fj, S )
            % Creates a new optimal sensor test.
            %
            % obj = sensorTest( M, Fj, S )
            %
            % ----- Inputs -----
            %
            % M: A model prior. A matrix (nState x nEns)
            %
            % Fj: A forward model used to estimate J, the sensor metric.
            %
            % S: A sensor sites object.
            
            % Use the default settings
            obj.replace = true;
            obj.nSensor = 1;
            obj.radius = NaN;
            
            % Set the values. Don't allow empty values for initial
            % constructor
            if nargin < 3
                error('Insufficient inputs.');
            end
            obj.setValues( M, Fj, S );
        end
    end
    
    % User methods
    methods
        
        % Run the sensor test
        output = run( obj );
        
        % Change the settings for the sensor test
        settings( obj, varargin );
        
        % Change the values in the sensor test
        setValues( obj, M, Fj, S );
        
    end
    
    % Static analysis utilities
    methods (Static)
        
        % Static call for optimal sensor test
        output = optimalSensor( M, Fj, sites, N, replace, radius );
        
        % Test how J variance is reduced for a sensor.
        skill = assessPlacement( Jdev, HMdev, R );
                
    end
        
    
end
        
    
    