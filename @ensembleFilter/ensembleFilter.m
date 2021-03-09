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
        Y;
        R;
        Rcov; % Whether R is variance or covariance
        whichRcov; % Which R covariance to use in each time step
        Ye;
        
        % Sizes
        nState = 0;
        nEns = 0;
        nPrior = 0;
        nSite = 0;
        nTime = 0;
        nRcov = 0;
    end
    
    % Basic inputs
    methods
        obj = rename(obj, name);
        obj = observations(obj, Y);
        obj = uncertainties(obj, R, isCov, whichCov);
        obj = prior(obj, M, whichPrior);
        obj = estimates(obj, Ye);
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