classdef vstempPSM < PSM
    % vstempPSM
    % Implements a PSM with a temperature-only version of VS-Lite
    %
    % vstempPSM Methods:
    %   vstempPSM - Creates a new vstempPSM object
    %   getStateIndices - Find state vector elements needed to run the model
    %   runForwardModel - Runs the PSM on an ensemble of input values
    %   vstemp - Static call to the vstemp function
    
    properties
        coord; % The [lat, lon] location of the proxy site
        T1;    % The lower temperature threshold below which growth = 0
        T2;    % The upper temperature threshold above which growth = 1
        intwindow;   % The monthly integration window
    end
    
    % Constructor
    methods        
        function obj = vstempPSM( lat, lon, T1, T2, varargin )
            
            % Parse, error check, set default
            [intwindow] = parseInputs( varargin, {'intwindow'}, {[]}, {[]} );
            if ~isempty(intwindow)
                obj.intwindow = (1:12)';
            end
            
            % Set values
            obj.lat = lat;
            obj.lon = lon;
            obj.T1 = T1;
            obj.T2 = T2;
            obj.intwindow = intwindow;
        end
    end
    
    % PSM methods
    methods
       
        % State indices
        getStateIndices( obj, ensMeta, Tname, monthNames, varargin )
            
        % Error checking
        errorCheckPSM(obj);
        
        % Runs the forward model
        [Ye, R] = runForwardModel( obj, M, ~, ~ );
            
    end
        
    % Static call to vstemp function
    methods (Static)
        width = vstemp( phi, T1, T2, T, varargin );
    end
         
end
        