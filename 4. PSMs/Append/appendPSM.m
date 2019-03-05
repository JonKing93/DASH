%% Defines a PSM for the "append" (Tardif) DA method. 
% A trivial PSM. Directly returns any inputs.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef appendPSM < PSM
    
    methods
        % Constructor
        function obj = appendPSM
        end
        
        % Set the value of H
        function[] = getStateIndices(obj, H)
            obj.H = H;
        end
        
        % Run the PSM. Simply return whatever value is input.
        function[Ye] = runPSM( ~, Ye)
        end
        
        % Convert units placeholder
        function[M] = convertM(~, M)
        end
        
        % Review PSM placeholder
        function[] = reviewPSM(~)
        end
    end
    
end
            
        
        
        
        