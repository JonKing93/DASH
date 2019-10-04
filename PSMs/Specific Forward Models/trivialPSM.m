classdef trivialPSM < PSM
    % trivialPSM
    % A trivial PSM used that directly returns whatever value it is given.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    methods
        % Constructor
        function obj = trivialPSM
        end
        
        % Set the value of H
        function[] = getStateIndices(obj, H)
            obj.H = H;
        end
        
        % Placeholder error check PSM method.
        function[] = errorCheckPSM(~)
        end
        
        % Run the PSM. Simply return whatever value is input. Just a
        % placeholder.
        function[Ye,R] = runForwardModel( ~, Ye, ~, ~)
            R = [];
        end
    end
end  