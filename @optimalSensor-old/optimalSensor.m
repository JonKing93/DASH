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

        % Output options
        return_metric = struct('initial', false, 'updated', false, 'final', false);
        
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
        obj = prior(obj, X);
        obj = psms(obj, F, R);
        obj = estimates(obj, Ye, R);
        obj = metric(obj, type, varargin);
        [bestSites, expVar, initialVar] = run(obj, N);
    end

    % Output options
    methods
        obj = returnMetric(obj, fields, returnFields);
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
        out = preallocateOutput(obj, N);
    end
    methods (Static)
        checkR(R, nSite);
    end

end
        