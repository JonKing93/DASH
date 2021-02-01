classdef ensemblePercentiles < ensembleCalculation
    
    properties
        percentiles;
    end
    
    methods
        function obj = deviationPercentiles(rows, percentiles)
            obj.rows = rows;
            obj.percentiles = percentiles;
        end
        function[Aperc] = calculate(Adev, Amean)
            Amean = permute(Amean, [1 3 2]);
            Aperc = prctile(Adev, obj.percentiles, 2);
            Aperc = Amean + Aperc;
        end
    end
    
end          