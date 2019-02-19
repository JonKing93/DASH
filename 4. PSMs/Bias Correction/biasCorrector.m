%% This class implements a bias-correcting plugin for the PSM class.
classdef biasCorrector < PSM
    
    properties
        jR;  % The saved rotation matrices
        jXs; % The save rotated Xs values.
        
        Xo;  % The observations
    end
    
    methods
        
        % Does the initial mapping and saves iteration variables
        function[] = initialMapping( obj, Xm, Xo, tol )
            
            % Run the Npdft
            [~, ~, obj.jR, obj.jXs] = npdft( Xm, Xo, tol );
            
            % Also save the observations for future reference
            obj.Xo = Xo;
        end
            
        function[] = biasCorrect( obj, 
            
            
            
            
        end
    
end
    