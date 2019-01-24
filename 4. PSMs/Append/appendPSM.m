%% Defines a PSM for the "append" (Tardif) DA method. Returns whatever value it is given.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef appendPSM < PSM
    
    methods
        % Constructor
        function obj = appendPSM
        end
        
        % Place holder for the getSampleIndices method. The sample indices
        % are calculated by dash.m, so no method is needed here.
        function[] = getSampleIndices(~)
        end
        
        % Run the PSM. Simply return whatever value is input.
        function[Ye] = runPSM( ~, Ye)
        end
    end
    
end
            
        
        
        
        