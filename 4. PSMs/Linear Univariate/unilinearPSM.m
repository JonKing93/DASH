% This implements a linear, univariate PSM
%
%
%
%
classdef unilinearPSM < PSM
    
    properties
        slope; % Linear slope
        intercept; % Linear intercept
        
        lat; % Coordinates
        lon; % Coordinates
    end
    
    methods
        
        function obj = unilinearPSM( slope, intercept, lat, lon )
            if ~isscalar(slope) || ~isscalar(intercept) || ~isscalar(lat) || ~isscalar(lon)
                error('All inputs to a unilinearPSM must be scalar.');
            end
            
            obj.slope = slope;
            obj.intercept = intercept;
            obj.lat = lat;
            obj.lon = lon;
        end
        
        function[Ye] = runPSM( obj, M, ~, ~ )
            Ye =  M .* obj.slope + obj.intercept;
        end
        
        function[] = getStateIndices( obj, ensMeta, varName )
            
            % Get the variable indices
            varDex = varCheck(ensMeta, varName);
            
            % Get the lat and lon dimension
            [~,~,lonDim, latDim] = getDimIDs;
            
            gridlat = ensMeta.(latDim)(varDex);
            gridlon = ensMeta.(lonDim)(varDex);
            
            % Get the closest sampling indices
            obj.H = samplingMatrix( [obj.lat, obj.lon], [gridlat, gridlon], 'linear');
        end
    end
end