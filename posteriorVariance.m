classdef posteriorVariance < posteriorCalculation
    %% Calculates the variance of a posterior ensemble.
    
    methods
        function[obj] = posteriorVariance
            obj.outputName = 'Avar';
        end
        
        function[Avar] = calculate(~, Adev, ~)
            nEns = size(Adev,2);
            Avar = sum(Adev.^2, 2) ./ (nEns-1);
        end
    end
    
end