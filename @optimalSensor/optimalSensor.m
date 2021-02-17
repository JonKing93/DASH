classdef optimalSensor
    
    properties
        name;
        M; % The prior ensemble
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
        obj = saveMeanArgs(obj, weights, rows);
        J = meanMetric(obj, A);
    end
    
    % Object utilities
    methods
        obj = rename(obj, name);
    end
    
end
        