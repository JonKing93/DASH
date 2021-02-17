classdef optimalSensor
    
    properties
        M; % The prior ensemble
        F; % PSMs
        R; % Observation uncertainty
        J; % The skill metric
        Ye; % The current estimates
        hasPSMs = false; % Whether using PSMs
        hasEstimates = false; % Whether using direct estimates
    end
    
    % Constructor
    methods
        function obj = optimalSensor
        end
    end
    
    % User methods
    methods
        obj = prior(obj, M);
        obj = psms(obj, F, R);
        obj = metric(obj, type, varargin);
        obj = estimates(obj, Ye);
    end
    
    % Metrics
    methods
        obj = weightedMean(obj, weights, rows, name);
    end
    
    % Object utilities
    methods
    end
    
end
        