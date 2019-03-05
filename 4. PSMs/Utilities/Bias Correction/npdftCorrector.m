%% This is a custom structure that holds variables for npdft bias-correction.
%
% obj = npdftCorrector( E, R, normO, normM, Xo, Xm )
classdef npdftCorrector
    
    properties
        E; % Energy convergence
        R; % Rotation matrices
        normO; % Normalization for Xo
        normM; % Normalization for Xm
        Xo; % Observational target dataset
        Xm; % Modeled source dataset
    end
    
    % Just a constructor
    methods
        function obj = npdftCorrector( E, R, normO, normM, Xo, Xm )
            obj.E = E;
            obj.R = R;
            obj.normO = normO;
            obj.normM = normM;
            obj.Xo = Xo;
            obj.Xm = Xm;
        end
    end
    
end