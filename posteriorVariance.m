classdef posteriorVariance < posteriorCalculation
    %% Calculates the variance of a posterior ensemble.
    
    properties (Constant)
        outputName = "Avar";
        timeDim = 2;
    end
    
    methods
        function[Avar] = calculate(~, Adev, Amean)
            
            % Sizes
            nEns = size(Adev,2);
            nTime = size(Amean,2);
            
            % Replicate variance over all time steps
            Avar = sum(Adev.^2, 2) ./ (nEns-1);
            Avar = repmat(Avar, [1 nTime]);
        end
        function[siz] = outputSize(~, nState, nTime, ~)
            siz = [nState, nTime];
        end 
    end
    
end