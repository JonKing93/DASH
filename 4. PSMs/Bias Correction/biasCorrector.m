%% This class implements a bias-correcting plugin for the PSM class.
classdef biasCorrector < handle
    
    properties
        rFo; % The CDF of the rotated observations
        rFm; % The CDF of the rotated model values
        R;   % The saved rotation matrices
        
        Xo;  % The observations
    end
    
    methods
        
        function[] = initialMapping( obj, )
            
            % Run the Npdft
            [Xs, R] = npdft( Xm, Xo, tol );
            
            % 
            
            
            
            
            
            
            
            
            
        end
    end
    
end
    