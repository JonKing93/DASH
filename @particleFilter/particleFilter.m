classdef particleFilter < ensembleFilter
    %% Implements a particle filter
    %
    % particleFilter Methods:
    %   particleFilter - Creates a new particleFilter object
    %   
    %   observations - Specify the proxy observations and uncertainties
    %   prior - Specify the prior ensemble
    %   estimates - Specify the proxy estimates
    %
    %   weighting - Select a weighting scheme for the particle filter
    %   run - Run the particle filter
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties
        weightType; % A switch for the weighting type: 1. Bayes, 2. Best N average
        weightArgs; % Arguments used to calculate weights
    end
    
    % Constructor
    methods
        function[pf] = particleFilter(name)
            %% Creates a new particleFilter object
            %
            % pf = particleFilter
            % Create a new particle filter
            %
            % pf = particleFilter(name)
            % Optionally give the particle filter an identifying name
            %
            % ----- Inputs -----
            %
            % name: An optional name for the particle filter. A string.
            %
            % ----- Outputs -----
            %
            % pf: The new particle filter object
            
            % Name
            if ~exist('name','var') || isempty(name)
                name = "";
            end
            pf = pf.rename(name);
            
            % Use the bayes weighting scheme by default
            pf = pf.weighting('bayes');
        end
    end
    
    % User methods
    methods
        pf = prior(pf, X, whichPrior);
        pf = estimates(pf, Y);
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