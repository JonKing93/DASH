classdef optimalSensor
    
    properties
        name;
        X; % The prior ensemble
        F; % PSMs
        R; % Observation uncertainty
        Ye; % The current estimates
        hasPSMs = false; % Whether using PSMs
        metricType;
        metricArgs;
        
        % Sizes
        nState;
        nEns;
        nSite;
    end
    
    % Constructor
    methods
        function obj = optimalSensor(name)
            if ~exist('name','var')||isempty(name)
                name = "";
            end
            obj = obj.rename(name);
        end
    end
    
    % User methods
    methods
        obj = prior(obj, M);
        obj = psms(obj, F, R);
        obj = estimates(obj, Ye);
        obj = metric(obj, type, varargin);
    end
    
    % Metrics
    methods
        J = computeMetric(obj, X);
        J = meanMetric(obj, A);
        obj = saveMeanArgs(obj, weights, rows);
    end
    
    % Object utilities
    methods
        obj = rename(obj, name);
    end
    
end
        