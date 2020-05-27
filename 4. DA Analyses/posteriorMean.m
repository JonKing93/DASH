classdef posteriorMean
    
    properties
        H;
        w;
    end
    
    methods
        function[postCalc] = run(obj, Amean, Adev)
            % Amean: nState x nTime
            % Adev: nState x nEns
            
            % Vectorizes the computation of weighted mean and variance for 
            % ensembles with different means and the same deviations.
            
            % The mean of an (ensemble of state vector weighted means) is 
            % the weighted mean of the (mean of the ensemble of state vectors)
            % (Try the math, it checks out)
            denom = sum(obj.w,1);
            postMean = sum(obj.w.*Amean,1) ./ denom;
            
            % The variance is derived from the weighted means of the
            % state vector ensemble deviations.
            sAdev = sum(obj.w.*Adev,1) ./ denom;
            unbias = 1 / (size(sAdev,2)-1);
            postVar = unbias * sum( sAdev.^2, 2) ;
            postVar = postVar * ones(size(postMean));
            
            % Output
            postCalc = [postMean', postVar'];
            postCalc = permute( postCalc, [3 2 1]);
            
        end
    end
end