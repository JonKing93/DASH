%% This class implements a bias-correcting plugin for the PSM class.
classdef biasCorrector < PSM
    
    properties
        Xo; % Observations
        Xm; % Initial ensemble
        
        R; % Saved rotation matrices
        E; % Energy statistic
        
        normO; % Normalization for the observations
        normM; % Normalization for the historical values
    end
    
    methods
        
        % Does the initial mapping and saves iteration variables
        function[X] = initialNPDFT( obj, Xo, Xm, tol, varargin )
            
            % Transpose from state vector
            Xo = Xo';
            Xm = Xm';
            
            % Run Npdft. Record static iteration values.
            [X, obj.E, obj.R, obj.normO, obj.normM] = npdft( Xo, Xm, tol, varargin{:} );
            
            % Save input values
            obj.Xo = Xo;
            obj.Xm = Xm;
            
            % Transpose output
            X = X';
        end
            
        function[X] = biasCorrect( obj, Xd )
            
            % Ensemble members become samples
            Xd = Xd';
            
            % Run a static npdft
            X = npdft_static( obj.Xo, obj.Xm, Xd, obj.R, obj.normO, obj.normM );
            
            % Flip back to state vector format
            X = X';
        end
    end
    
end