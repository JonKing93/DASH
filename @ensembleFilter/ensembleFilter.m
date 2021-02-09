classdef (Abstract) ensembleFilter
    %% Implements common utilities for ensemble-based data assimilation
    % filters (i.e. Kalman filters and particle filters)
    
    properties        
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
    
    % Constructor
    methods
        function[obj] = ensembleFilter(name)
            % Default name
            if ~exist('name','var') || isempty(name)
                name = "";
            end
            obj = obj.rename(name);
        end
    end
    
    % Basic inputs
    methods
        obj = rename(name);
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
    end
    methods (Static)
        [nDim1, nDim2, nDim3] = checkInput(X, name, allowNaN, requireMatrix);
    end
    
end