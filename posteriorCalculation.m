classdef (Abstract) posteriorCalculation
    %% Implements calculations that require the posterior deviations
    % (and optionally the posterior mean) from a Kalman Filter
    
    properties (Abstract, Constant)
        outputName; % The name of the calculated value in the output structure
        timeDim; % The time dimension in the output quantity 
    end
    
    methods (Abstract)
        value = calculate(obj, Adev, Amean);
    end
    
end