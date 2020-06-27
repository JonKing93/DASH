classdef myClassB < myClassA
    
    properties
        w;
    end
    
    methods
        function obj = myClassB(arg1)
            obj@myClassA(arg1);
            obj.w = 5;
        end
    end
    
end