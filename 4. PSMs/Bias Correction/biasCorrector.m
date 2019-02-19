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
            [~, ~, obj.staticNPDFT] = npdft( Xm, Xo, tol, 5 );
            
            warning('fixed iter');
            
            % Also save the observations for future reference
            obj.Xo = Xo;
        end
            
        function[X] = biasCorrect( obj, Xd )
            
            % Ensemble members become samples
            Xd = Xd';
            
            % Run a static npdft
            X = npdft_static( Xd, obj.Xo, obj.staticNPDFT{:} );
            
            % Flip back to state vector format
            X = X';
        end
    end
    
end