%% This class implements a linear, univariate PSM
classdef linearPSM < PSM
    % This is a univariate, vectorizable PSM.
    
    % The slope and intercept should be fixed values for the PSM
    properties
        slope;        % The slope of the linear models.
        intercept;    % The intercept of the linear models.
    end
    
    % It implements the abstract method runPSM
    methods
        
        % Run a univariate linear model.
        function[Ye] = runPSM( obj, M, obDex, ~, ~)
            
            % Set obDex if it does not exist
            if ~exist('obDex','var')
                obDex = [];
            end
            
            % Get the indices of the model variables to use
            varDex = obj.getObIndex( obDex );
            
            % Apply the linear model to all relevant observations.
            Ye = obj.intercept(varDex) + (obj.slope(varDex) .* M);
        end
        
        % This is a constructor of a linearPSM. It sets the slope and
        % intercept.
        function obj = linearPSM(intercept, slope, obDex)
            % Set the values
            obj.slope = slope;
            obj.intercept = intercept;
            
            % Set the obDex to the linear index if unspecified.
            if ~exist('obDex','var')
                obDex = 1:numel(slope);
            end
            obj.obDex = obDex;
        end
    end  
end   