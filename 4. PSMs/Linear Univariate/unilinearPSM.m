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
        
        addUnit;
    end
    
    methods
        
        function obj = unilinearPSM( slope, intercept, lat, lon, varargin )
            
            [obj.addUnit] = parseInputs( varargin, {'addUnit'}, {0}, {[]} );
            
            if ~isscalar(slope) || ~isscalar(intercept) || ~isscalar(lat) || ~isscalar(lon)
                error('All inputs to a unilinearPSM must be scalar.');
            end
            
            obj.slope = slope;
            obj.intercept = intercept;
            obj.lat = lat;
            obj.lon = lon;
        end
        
        function[Ye] = runPSM( obj, M, ~, ~ )
            M = obj.convertM(M);
            Ye =  M .* obj.slope + obj.intercept;
        end
        
        function[M] = convertM( obj, M )
            M = M + obj.addUnit;
        end
        
        function[] = getStateIndices( obj, ensMeta, varName, varargin )
            
            [time, lev] = parseInputs( varargin, {'time','lev'}, {[],[]}, {[],[]} );
            
            % Get the variable indices
            varDex = varCheck(ensMeta, varName);
            
            % Restrict by time or lev
            if ~isempty(time)
                dimCheck(ensMeta, 'time');
                varDex = varDex( findincell(time, ensMeta.time(varDex)) );
            end
            if ~isempty(lev)
                dimCheck(ensMeta,'lev');
                varDex = varDex( findincell(lev, ensMeta.lev(varDex)) );
            end
            
            % Get the lat and lon dimension
            [~,~,lonDim, latDim] = getDimIDs;
            
            gridlat = cell2mat( ensMeta.(latDim)(varDex) );
            gridlon = cell2mat( ensMeta.(lonDim)(varDex) );
            
            % Get the closest sampling indices
            obj.H = samplingMatrix( [obj.lat, obj.lon], [gridlat, gridlon], 'linear');
        end
        
    end
end