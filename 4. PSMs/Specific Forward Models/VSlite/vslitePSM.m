classdef vslitePSM < PSM
    
    properties
        lat;
        lon
        
        T1;
        T2;
        M1;
        M2;
        
        Tclim;
        standard;
        
        intwindow;
        lbparams;
        hydroclim;
    end
    
    
    methods
        
        % Constructor
        function obj = vslitePSM( coord, T1, T2, M1, M2, Tclim, varargin )
            
            % Parse inputs
            [intwindow, lbparams, hydroclim] = ...
                parseInputs( varargin, {'lbparams','hydroclim','intwindow'}, ...
                {[],[],[]}, {[],{'P','M'},[]} );
            
            % Defaults
            obj.intwindow = {};
            obj.lbparams = {};
            obj.hydroclim = {};
            obj.standard = [];
            
            % Advanced parameters
            if ~isempty(intwindow)
                obj.intwindow = {'intwindow', intwindow};
            end
            if ~isempty(lbparams)
                obj.lbparams = {'lbparams', lbparams};
            end
            if ~isempty(hydroclim)
                obj.hydroclim = {'hydroclim', hydroclim};
            end
            
            % Set other values
            obj.lat = coord(1);
            obj.lon = coord(2);
            obj.T1 = T1;
            obj.T2 = T2;
            obj.M1 = M1;
            obj.M2 = M2;
            obj.Tclim = Tclim;
        end
        
        % State indices
        function[] = getStateIndices( obj, ensMeta, Tname, Pname, monthName, varargin )
            
            % Concatenate the variable names
            varNames = [string(Tname), string(Pname)];
            
            % Get the time dimension
            [~,~,~,~,~,~,timeID] = getDimIDs;
            
            
            % Get the closest indices
            obj.H = getClosestLatLonIndex( [obj.lat, obj.lon], ensMeta, ...
                                           varNames, timeID, monthName, varargin{:} );
        end
        
        % Error Checking
        function[] = errorCheckPSM(obj)
            warning('VS-Lite PSMs have no error checking!!!');
        end
        
        % Run the PSM
        function[Ye] = runForwardModel( obj, M, ~, ~ )
            
            % Split the state vector into T and P
            T = M(1:12,:);
            P = M(13:24,:);
            
            % Run the model
            Ye = VSLite4dash( obj.lat, obj.T1, obj.T2, obj.M1, obj.M2, ...
                               T, P, obj.standard, obj.Tclim, obj.intwindow{:}, ...
                               obj.lbparams{:}, obj.hydroclim{:} );
                           
            % Standardize
            Ye = zscore(Ye);
        end
        
    end
end
                           