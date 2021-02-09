classdef particleFilter
    
    properties
        name;
        M;
        whichPrior;
        D;
        R;
        Y;
        
        % Sizes
        nState = 0;
        nEns = 0;
        nPrior = 0;
        nSite = 0;
        nTime = 0;
    end
    
    % Constructor
    methods
        function[obj] = particleFilter()
        end
    end
    
    % User methods
    methods
        prior;
        observations;
        estimates;
        weightScheme;
    end
       
    % Object utilities
    methods
    end 
    
end