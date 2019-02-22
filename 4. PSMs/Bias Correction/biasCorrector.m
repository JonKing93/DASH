%% This class implements a bias-correcting plugin for the PSM class.
classdef biasCorrector < PSM
    
    properties
        Xo; % Observations
        Xm; % Calibration period
        Xp; % Initial ensemble
        
        R; % Saved rotation matrices
        
        normO; % Normalization for the observations
        normM; % Normalization for the historical values
        
        type; % Type of qdm
    end
    
    methods
        
        % Does the initial mapping and saves iteration variables
        function[] = initialMapping( obj, Xo, Xm, Xp, type, tol, varargin )
            
            % Run MBCn on the values
            [~, obj.R, obj.normO, obj.normM] = MBCn( Xo, Xm, Xp, type, tol, varargin{:} );
            
            % Also save the input values
            obj.Xo = Xo;
            obj.Xm = Xm;
            obj.Xp = Xp;
            obj.type = type;
        end
            
        function[X] = biasCorrect( obj, Xd )
            
            % Ensemble members become samples
            Xd = Xd';
            
            % Run a static MBCn
            X = MBCn_static( obj.Xo, obj.Xm, obj.Xp, Xd, obj.R, ...
                             obj.type, obj.normO, obj.normM );
            
            % Flip back to state vector format
            X = X';
        end
    end
    
end