classdef linearPSM < PSM
    % linearPSM
    % Implements a multivariate linear proxy system model.
    %
    % linearPSM Methods:
    %   linearPSM - Creates a new linearPSM object
    %   getStateIndices - Find the state vector elements needed to run the PSM
    %   runForwardModel - Runs the multivariate linear forward model.
    %   linearModel - Static function implementing the linear model
    
    properties
        coord;       % Proxy site coordinates, [lat, lon]
        slopes;      % The multiplicative constant to apply to each variable
        intercept;   % The additive constant
        Hlim;        % The limits of the state elements associated with each slope
    end
    
    % Constructor
    methods
        function obj = linearPSM( lat, lon, slopes, intercept )
            % Creates a linear PSM object
            %
            % obj = linearPSM( lat, lon, slopes, intercept )
            % Creates a new multivariate linear PSM. Note that slopes may
            % apply to the mean of several state vector elements. See
            % getStateIndices for details on this functionality.
            %
            % ----- Inputs -----
            %
            % slopes: A vector containing the multiplicative constant to
            %         apply to each subsequent variable.
            %
            % intercept: The scalar additive constant
            %
            % lat: Latitude coordinate of the proxy site
            %
            % lon: Longitude coordinate of the proxy site
            
            % Error check            
            if ~isvector(slopes) || ~isnumeric(slopes) || ~isreal(slopes)
                error('slopes must be a numeric vector.')
            elseif ~isscalar(intercept) || ~isnumeric(intercept) || ~isreal(intercept)
                error('intercept must be a numeric scalar.');
            elseif ~isscalar(lat) || ~isscalar(lon) || ~isnumeric(lat) || ~isnumeric(lon)
                error('lat and lon must be numeric scalars.');
            end
            
            % Save
            obj.slopes = slopes(:);
            obj.intercept = intercept;
            obj.coord = [lat, lon];
        end
    end
    
    % PSM methods
    methods
        
        % State indices
        getStateIndices( obj, ensMeta, varNames, searchParams );
        
        % Error checking
        errorCheckPSM( obj );
        
        % Run the forward model
        [Ye, R] = runForwardModel( obj, M, ~, ~ );
        
    end
    
    % Static call to linear model function
    methods (Static)
        Y = linearModel( X, slopes, intercept );
    end
    
end