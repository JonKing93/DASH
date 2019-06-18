%% This is a less verbose psm template

classdef psmName < PSM
    
    properties
        coords;  % Site coordinates
        
        someProp;    % another properties
        default_100 = 100;   % Property with default value
    end
    
    methods
        
        %% Constructor
        function obj = psmName( coord, prop, varargin )
            obj.coords = coord;
            obj.someProp = prop;
            
            % Change values of default
            if nargin == 4
                obj.default_100 = 100;
            end
        end
        
        %% Get state indices
        function[] = getStateIndices( obj, ensMeta, varNames )
            obj.H = someFunction( ensMeta, varNames );
        end
        
        %% Review PSM
        function[] = errorCheckPSM( obj )
                        
            % Some error checking examples
            if obj.coord(1) < -90 || obj.coord(1) > 90
                error('Latitude must be on [-90 90]');
            end
            if isnan( obj.someProp )
                error('someProp cannot be NaN');
            end
            
        end
            
       
        
         
        %% Run the PSM
        function[Ye, R] = runForwardModel( obj, M, ~, ~ )
            
            % Run the forward model
            Ye = myForwardModel( M, obj.someProp );
            
            % Optionally calculate R
            R = someFunction( Ye );
        end
    end
end