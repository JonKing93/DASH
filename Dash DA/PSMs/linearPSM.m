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
        function[Ye] = runPSM( obj, M, obNum, ~, ~)
            
            % Get the indices of the current observation
            obDex = obj.getObIndex( obNum );
            
            % Apply the linear model to all relevant observations.
            Ye = obj.intercept(obDex) + (obj.slope(obDex) .* M);
        end
        
        % This is a constructor of a linearPSM. It sets the slope and
        % intercept.
        function obj = linearPSM(intercept, slope, obNum)
            % Set the values
            obj.slope = slope;
            obj.intercept = intercept;
            obj.obNum = obNum;
        end
    end  
end   