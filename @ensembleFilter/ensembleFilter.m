classdef (Abstract) ensembleFilter
    %% Implements common utilities for ensemble-based data assimilation
    % filters (i.e. Kalman filters and particle filters)
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = private)
        name;
        
        % Essential inputs
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
    
    % Basic inputs
    methods
        obj = rename(obj, name);
        obj = prior(obj, M, whichPrior);
        obj = observations(obj, D, R);
        obj = estimates(obj, Y);
    end
    
    % Interface to run
    methods (Abstract)
        out = run(obj);
    end
    
    % Utilities
    methods
        whichArg = parseWhich(obj, whichArg, name, nIndex, indexName);
        obj = finalize(obj, actionName);
    end
    methods (Static)
        [nDim1, nDim2, nDim3] = checkInput(X, name, allowNaN, requireMatrix);
    end
    
end