classdef posteriorMean
    
    properties
        H;
        w;
    end
    
    methods
        function[postMean] = run(obj, Apsm)
            
            % Take the weighted mean
            postMean = sum( obj.w.*Apsm, 1 ) ./ sum(obj.w,1);
        end
    end
end