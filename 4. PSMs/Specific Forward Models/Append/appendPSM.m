%% Defines a PSM for the appended DA method
%
% This is a trivial PSM. It directly returns any inputs.

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
            
        
        
        
        