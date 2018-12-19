%% This defines a simple exponential model where Y = Ae^(Bx)
classdef simpleExpPSM < UnivarVectorPSM
    % This is a univariate, vectorizable equation.
    
    properties
        scale;
        B;
    end
    
    methods
        
        % Constructor, set the values in the exponential model.
        function obj = simpleExpPSM( scale, B, obNum )
            obj.scale = scale;
            obj.B = B;
            obj.obNum = obNum;
        end
        
        % Implement the PSM for DA
        function[Ye] = runPSM(obj,M,obNum,~,~)
            
            % Get the index of the observations in the model
            obDex = obj.getObIndex(obNum);
            
            % Implement the model
            Ye = 1./ (obj.scale(obDex) .* exp( obj.B(obDex) .* M ));
        end 
    end
end