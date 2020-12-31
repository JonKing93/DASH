classdef posteriorIndex < posteriorCalculation
    
    properties (SetAccess = immutable)
        outputName;
        timeDim = 2;
    end
    
    properties (SetAccess = private)
        weights;
        denom;
        rows;
    end
    
    methods
        function[siz] = outputSize(~, ~, nTime, nEns)
            siz = [nEns, nTime];
        end
        function[obj] = posteriorIndex(name, weights, rows)
            obj.name = string(strcat('index_', name));
            obj.weights = weights;
            obj.denom = sum(weights,1);
            obj.rows = rows;
        end
        function[index] = calculate(obj, Adev, Amean)
            Amean = Amean(obj.rows,:);
            Adev = Adev(obj.rows,:);
            
            devsum = sum(obj.weights .* Adev, 1) ./ obj.denom;
            meansum = sum(obj.weights .* Amean, 1) ./ obj.denom;
            index = devsum' + meansum;
        end
    end 
end