classdef (Abstract) ensembleCalculation
    
    properties
        rows;
    end
    
    methods (Abstract)
        X = calculate(M);
    end
    
end