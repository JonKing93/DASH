%% This class implements a bias-correcting plugin for the PSM class.
%
% Runs an initial Npdft to produce a static npdft mapping. Then applies a
% static npdft during each serial update.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL MAPPING:
%
% initialNPDFT( Xo, M, tol )
% Creates a static Npdft mapping that satisfies an energy-distance
% convergence threshold. Selects source data from the initial model
% ensemble.
%
% initialNPDFT(  Xo, M, tol, nIter )
% Specifies a maximum number of Npdft iterations.
%
% ----- Inputs -----
%
% Xo: Observed values. The target distribution. (nVariables x nObs)
%
% M: An initial model ensemble. (nState x nEns )
%
% tol: An energy distance convergence threshold.
%
% nIter: A maxmimum number of iterations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BIAS CORRECTION:
% 
% X = biasCorrect( Xd )
% Applies a static npdft to DA variables.
%
% ----- Inputs -----
% 
% Xd: Climate variables from a DA. (nVar x nEns)
%
% ----- Outputs -----
% 
% X: Bias corrected values

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
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
        function[] = initialNPDFT( obj, Xo, M, tol, varargin )
            
            % Check that sampling indices were generated
            if isempty(obj.H)
                error('Cannot run an initial NPDFT until the sample indices are generated.');
            end            
                           
            % Select at sampling indices and convert units
            M = M( obj.H, : );
            M = obj.convertM(M);
            
            % Transpose from state vector for npdft
            Xo = Xo';
            M = M';
            
            % Run Npdft. Record static iteration values.
            [~, obj.E, obj.R, obj.normO, obj.normM] = npdft( Xo, M, tol, varargin{:} );
            
            % Save input values
            obj.Xo = Xo;
            obj.Xm = M;
        end
            
        % Performs a bias correction on DA climate variables.
        function[X] = biasCorrect( obj, Xd )
            
            % Convert units
            Xd = obj.convertM( Xd );
            
            % Ensemble members become samples
            Xd = Xd';
            
            % Run a static npdft
            X = npdft_static( obj.Xo, obj.Xm, Xd, obj.R, obj.normO, obj.normM );
            
            % Flip back to state vector format
            X = X';
        end
    end
    
    % This requires bias correcting PSMs to include a unit converter
    methods (Abstract = true)
        M = convertM(M);
    end
    
end