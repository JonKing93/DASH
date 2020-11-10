classdef (Abstract) posteriorCalculation
    %% Implements calculations that require the posterior deviations
    % (and optionally the posterior mean) from a Kalman Filter
    
    properties
        outputName;
    end
    
    methods (Abstract)
        value = calculate(obj, Adev, Amean);
    end
    
end