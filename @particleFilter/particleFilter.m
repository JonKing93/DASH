classdef particleFilter < ensembleFilter
    %% Implements a particle filter
    
    properties
        weightType; % A switch for the weighting type: 1. Bayes, 2. Best N average
        weightArgs; % Arguments used to calculate weights
    end
    
    % Constructor
    methods
        function[obj] = particleFilter()
        end
    end
    
    % User methods
    methods
        out = run(pf);
        pf = weighting(pf, type, N);
    end
       
    % Weights utilities
    methods
        w = weights(pf, sse);
    end
    methods (Static)
        w = bayesWeights(sse);
        w = bestWeights(sse, N);
    end
    
end