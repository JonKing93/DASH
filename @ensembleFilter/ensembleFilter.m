classdef (Abstract) ensembleFilter
    %% Implements common utilities for ensemble-based data assimilation
    % filters (i.e. Kalman filters and particle filters)
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = private)
        name;
        
        % Essential inputs
        Y;
        Ye;
        X;
        whichPrior;
        R;
        whichR;
        Rcov;
        
        % Sizes
        nState = 0;
        nEns = 0;
        nPrior = 0;
        nSite = 0;
        nTime = 0;
        nR = 0;
    end
    
    % Basic inputs
    methods
        obj = rename(obj, name);
        obj = observations(obj, Y);
        obj = uncertainties(obj, R, whichR, isCov);
        obj = prior(obj, X, whichPrior);
        obj = estimates(obj, Ye);
    end
    
    % User query
    methods
        Rcov = Rcovariance(obj, t, s);
    end
    
    % Utilities
    methods
        whichArg = parseWhich(obj, whichArg, name, nIndex, indexName);
        obj = finalize(obj, actionName);
        checkMissingR(obj);
    end
    methods (Static)
        [nDim1, nDim2, nDim3] = checkInput(X, name, allowNaN, requireMatrix);
    end
    
end