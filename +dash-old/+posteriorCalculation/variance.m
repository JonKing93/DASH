classdef variance < dash.posteriorCalculation.Interface
    %% Calculates the variance of a posterior ensemble.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = immutable)
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
    methods (Static)
        function[name] = outputName
            name = "Avar";
        end
    end
    
end