classdef nullCorrector < biasCorrector
    % nullCorrector
    % Implements no bias correction
    
    properties
    end
    
    methods
        % Constructor
        function obj = nullCorrector
            obj.type = "none";
        end
        
        % Null Error checking
        function[] = review(~)
        end
        
        % Null bias correction
        function[M] = biasCorrect(~,M)
        end
    end
    
end
            
    
    