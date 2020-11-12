classdef posteriorPercentiles < posteriorCalculation
    %% Calculates percentiles of a posterior ensemble.
    
    properties (Constant)
        outputName = "Aperc";
        timeDim = 3;
    end
    
    properties (SetAccess = private)
        percentiles;
    end
    
    methods
        function[obj] = posteriorPercentiles(percentiles)
            
            % Error check
            assert(isvector(percentiles), 'percentiles must be a vector');
            assert(isnumeric(percentiles), 'percentiles must be numeric');
            assert( all(percentiles>=0 & percentiles<=100), 'percentiles must be between 0 and 100');
            
            % Save
            obj.percentiles = percentiles;
        end      
        function[Aperc] = calculate(obj, Adev, Amean)
            Aperc = prctile(Adev, obj.percentiles, 2) + permute(Amean, [1 3 2]);
        end
        function[siz] = outputSize(obj, nState, nTime, ~)
            siz = [nState, numel(obj.percentiles), nTime];
        end
    end
end 