%% This is a less verbose psm template

classdef psmName < PSM
    
    properties
        coords;  % Site coordinates
        unitConvert;  % Unit conversion
        
        someProp;    % another properties
        default_100 = 100;   % Property with default value
    end
    
    methods
        
        %% Constructor
        function obj = psmName( coord, unit, prop, varargin )
            obj.coords = coord;
            obj.unitConvert = unit;
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
        function[] = reviewPSM( obj )
            
            % Check for sampling indices
            if isempty(obj.H)
                error('Need to generate sampling indices.');
            end
            
            %%%%%  Insert Error checking here %%%%%
            
            % Some error checking examples
            if obj.coord(1) < -90 || obj.coord(1) > 90
                error('Latitude must be on [-90 90]');
            end
            if isnan( obj.someProp )
                error('someProp cannot be NaN');
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
            
        
        %% Unit conversion
        function[M] = convertUnits( obj, M )
            
            % Additive
            M = M + obj.unitConvert;
            
            % Multiplicative
            M = M .* obj.unitConvert;
            
            % More complex
            M = someFunction( M, obj.unitConvert );
            
        end
        
         
        %% Run the PSM
        function[Ye, R] = runPSM( obj, M, ~, ~ )
            
            % Convert units
            M = obj.convertUnits( M );
            
            % Bias correct
            M = myBiasCorrection( M );
            
            % Run the forward model
            Ye = myForwardModel( M, obj.someProp );
            
            % Optionally calculate R
            R = someFunction( Ye );
        end
    end
end