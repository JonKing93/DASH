%% This class implements a bias-correcting plugin for the PSM class.
classdef biasCorrector < PSM
    
    properties
        staticNPDFT; % The iteration values needed to run a static npdft
        Xo;  % The observations
    end
    
    methods
        
        % Does the initial mapping and saves iteration variables
        function[] = initialMapping( obj, Xm, Xo, tol )
            % Run the Npdft
            [~, ~, obj.staticArgs] = npdft( Xm, Xo, tol );
            
            % Also save the observations for future reference
            obj.Xo = Xo;
        end
            
        function[X] = biasCorrect( obj, Xd )
            % Run a static npdft
            X = npdft_static( Xd, obj.Xo, obj.staticArgs{:} );
        end
    end
    
end