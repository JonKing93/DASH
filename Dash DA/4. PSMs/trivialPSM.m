%% Defines a trivial PSM. Returns whatever value it is given. Useful for
% the appended DA method.
classdef trivialPSM < PSM
    
    methods
        % Constructor
        function obj = trivialPSM
        end
        
        % Place holder for sample indices
        function[] = getSampleIndices(~)
        end
        
        % Run the PSM
        function[Ye] = runPSM( ~, Ye)
        end
    end
    
end
            
        
        
        
        