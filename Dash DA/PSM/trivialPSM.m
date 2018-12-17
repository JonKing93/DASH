%% This class implements the trivial PSM, which simply returns the input values.
% It is useful as the PSM for the Tardif method, since the Ye are updated
% through the Kalman Gain and thus need no PSM.
classdef trivialPSM < PSM
    
    methods     
        % Implement the runPSM method. No metadata is needed. Simply return
        % the input value.
        function[Ye] = runPSM( ~, M, ~, ~, ~, ~ )
            Ye = M;
        end
        
        % This is the constructor of a trivialPSM. No setup is needed.
        function obj = trivialPSM
        end
    end
    
end