classdef (Abstract) posteriorCalculation
    %% Implements calculations that require the posterior deviations
    % (and optionally the posterior mean) from a Kalman Filter
    
    properties (Abstract, SetAccess = immutable)
        timeDim; % The time dimension in the output quantity
    end
    
    methods (Abstract)
        value = calculate(obj, Adev, Amean);
        siz = outputSize(obj, nState, nTime, nEns);
        name = outputName(obj);
    end
    
end