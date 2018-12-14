%% This class implements a linear, univariate PSM
classdef linearPSM < PSM
    
    % The slope and intercept should be fixed values for the PSM
    properties (SetAccess = immutable)
        slope;        % The slope of the linear models.
        intercept;    % The intercept of the linear models.
    end
    
    % It implements the abstract method runPSM
    methods
        
        % Implement runPSM for a single linear model
        function[Ye] = runPSM( obj, M, ~, obDex, ~, ~)
            
            % If no specific index is given, use all models
            if ~exist('obDex','var') || isempty(obDex)
                obDex = 1:numel(obj.slope);
            end
            
            % Apply the linear model to all sites of interest.
            Ye = obj.intercept(obDex) + (obj.slope(obDex) .* M);
        end

        
        % This is a constructor of a linearPSM. It sets the slope and
        % intercept.
        function obj = linearPSM(slope, intercept)
        %% obj = linearPSM(slope, intercept)
        
            % Set the values
            obj.slope = slope;
            obj.intercept = intercept;
        end  
    end
end     