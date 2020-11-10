classdef posteriorPercentiles < posteriorCalculation
    %% Calculates percentiles of a posterior ensemble.
    
    properties
        percentiles;
    end
    
    methods
        function[obj] = posteriorPercentiles(percentiles)
            warning('Error check percentiles');
            obj.outputName = 'Aperc';
        end
        
        function[Aperc] = calculate(obj, Adev, ~)
            Aperc = prctile(Adev, obj.percentiles, 2);
        end
    end
    
end 