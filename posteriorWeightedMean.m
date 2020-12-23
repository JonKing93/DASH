classdef posteriorWeightedMean < posteriorCalculation
    
    properties (Constant)
        outputName = "ts";
        timeDim = 2;
    end
    
    properties (SetAccess = private)
        weights;
        denom;
    end
    
    methods
        function[siz] = outputSize(~, ~, nTime, nEns)
            siz = [nEns, nTime];
        end
        function[obj] = posteriorWeightedMean(weights)
            obj.weights = weights;
            obj.denom = sum(weights,1);
        end
        function[ts] = calculate(obj, Adev, Amean)
            devsum = sum(obj.weights .* Adev, 1) ./ obj.denom;
            meansum = sum(obj.weights .* Amean, 1) ./ obj.denom;
            ts = devsum' + meansum;
        end
    end 
end
        
            
            
        