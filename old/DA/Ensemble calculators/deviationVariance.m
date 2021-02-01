classdef deviationVariance < ensembleCalculation
    
    properties
        nEns;
    end
    
    methods
        function obj = ensembleVariance(nRows, nEns)
            obj.rows = (1:nRows)';
            obj.nEns = nEns;
        end
        function[Avar] = calculate(Adev)
            Avar = sum(Adev.^2, 2) ./ (obj.nEns-1);
        end
    end
    
end
            