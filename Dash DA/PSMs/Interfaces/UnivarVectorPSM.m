%% This defines the implementation of calculateYe for any univariate, vectorizable PSM.
classdef(Abstract) UnivarVectorPSM < PSM & appendPSM
    
    methods
        % All univariate PSMs will use this implementation
        function[Ye] = calculateYe( obj, M, H, obNum )
            
            % Convert H to a vector
            H = cell2mat(H);
            
            % Just use the normal runPSM method for the bulk calculation
            Ye = obj.runPSM( M(H,:), obNum);
        end
    end
end