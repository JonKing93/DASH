classdef percentiles < dash.posteriorCalculation.Interface
    %% Calculates percentiles of a posterior ensemble.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = immutable)
        timeDim = 3;
    end
    
    properties (SetAccess = private)
        percs;   % The queried percentiles
    end
    
    methods
        function[obj] = percentiles(percs)
            
            % Error check
            assert(isvector(percs), 'percentiles must be a vector');
            assert(isnumeric(percs), 'percentiles must be numeric');
            assert( all(percs>=0 & percs<=100), 'percentiles must be between 0 and 100');
            
            % Save
            obj.percs = percs;
        end      
        function[Aperc] = calculate(obj, Adev, Amean)
            Aperc = prctile(Adev, obj.percs, 2) + permute(Amean, [1 3 2]);
        end
        function[siz] = outputSize(obj, nState, nTime, ~)
            siz = [nState, numel(obj.percs), nTime];
        end
    end
    methods (Static)
        function[name] = outputName
            name = "Aperc";
        end
    end
end 