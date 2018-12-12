%% This class implements the linear T PSM for NTREND
classdef linearPSM < PSM
    
    % The actual linear model should never be changed.
    properties (SetAccess = immutable)
        linMod;
        coord;
    end
    
    % Set the filename here for easy debugging
    properties (Constant)
        file = 'linear_T_model.mat';
    end
    
    % It implements the abstract method runPSM
    methods
        
        % This implements the abstract method, runPSM from the PSM
        % superclass. Doesn't actually need information on time.
        function[Ye] = runPSM( obj, M, coord, ~)
            % Start by getting the linear model site closest to the M site
            H = samplingMatrix( coord, obj.coord, 'linear');
            
            % Then, update
            Ye = obj.linMod(H,1) + (obj.linMod(H,2) * M);
        end
        
        % This calculates all Ye in one go.
        function[Ye] = buildYe( obj, M )
            % Calculate all the Ye
            Ye = obj.linMod(:,1) + (obj.linMod(:,2) .* M);
        end
        
        % This is a constructor for the linear model.
        function obj = linearPSM
            % Load the model
            linMod = load( obj.file );
            
            % Set the values in the class
            obj.linMod = linMod.linMod;
            obj.coord = [linMod.lat, linMod.lon];
        end
        
    end
    
end
            
            