classdef simpleExpPSM < PSM
    
    properties
        scale;
        B;
    end
    
    methods
        
        function obj = simpleExpPSM( scale, B )
            obj.scale = scale;
            obj.B = B;
        end
        
        function[Ye] = runPSM(obj,M,~,~,~)
            Ye = obj.scale .* exp( obj.B .* M );
        end
    end
    
end