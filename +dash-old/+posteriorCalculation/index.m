classdef index < dash.posteriorCalculation.Interface
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = immutable)
        name;
        timeDim = 2;
    end
    
    properties (SetAccess = private)
        weights;
        rows;
        nanflag;
    end
    
    methods
        function[siz] = outputSize(~, ~, nTime, nEns)
            siz = [nEns, nTime];
        end
        function[obj] = index(name, weights, rows, nanflag)
            obj.name = name;
            obj.weights = weights;
            obj.rows = rows;
            obj.nanflag = nanflag;
        end
        function[index] = calculate(obj, Adev, Amean)
            
            % Extract the relevant data
            Amean = Amean(obj.rows,:);
            Adev = Adev(obj.rows,:);
            
            % Exclude NaN values
            nans = isnan(obj.weights);
            Amean(nans,:) = NaN;
            Adev(nans, :) = NaN;
            
            % Get the denominator after accounting for NaN
            w = obj.weights;
            w(isnan(Amean(:,1))) = NaN;
            denom = sum(w, 'omitnan');
            
            % Get the index
            devsum = sum(obj.weights.*Adev, 1, obj.nanflag) ./ denom;
            meansum = sum(obj.weights.*Amean, 1, obj.nanflag) ./ denom;
            index = devsum' + meansum;
        end
        function[name] = outputName(obj)
            name = obj.name;
        end
    end 
end