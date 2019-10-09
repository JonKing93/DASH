classdef sensorSites
    % sensorSites
    % Holds information on possible sensor placements
    
    properties
        H;    % State vector indices
        R;    % Site observation uncertainty
        coordinates;    % lat-lon coordinates of each site
    end
    
    % Constructor
    methods 
        function obj = sensorSites( H, R, coordinates )
            % Creates a new sensorSites object
            %
            % obj = sensorSites( H, R, coordinates )
            %
            % ----- Inputs -----
            %
            % H: State vector indices for each site (nSite x 1)
            %
            % R: Observation uncertainty for each site (nSite x 1)
            %
            % coordinates: Lat-lon coordinates for each site. A two column
            %     matrix. First column is lat, second is lon. (nSite x 2)
            %
            % ----- Outputs -----
            %
            % obj: The new sensorSites object
            
            % Error check
            if ~isvector(H) || ~isnumeric(H) || ~isreal(H) || any(mod(H,1)~=0) || any(H<0)
                error('H must be a vector of positive integers.');
            elseif ~isvector(R) || ~isnumeric(R) || ~isreal(R) || any(R<0) || length(R)~=length(H)
                error('R must be a vector of positive values and must have as many elements as H.');
            elseif ~ismatrix(coordinates) || ~isnumeric(coordinates) || ~isreal(coordinates) || size(coordinates,1)~=length(H) || size(coordinates,2)~=2
                error('coordinates must be a 2 column matrix of real values with a row for each element in H (%.f).', length(H) );
            end
    
            % Record values
            obj.H = H(:);
            obj.R = R(:);
            obj.coordinates = coordinates;
        end
    end
    
    % Remove sites
    methods
        
        % Remove single site
        function[obj] = removeSite( obj, remove )
            % Removes site from a sensor array
            obj.H(remove) = [];
            obj.R(remove) = [];
            obj.coordinates(remove,:) = [];
        end
        
        % Remove sites in radius
        function[obj] = removeRadius( obj, best, radius )
            if ~isnan(radius)
                dist = haversine( obj.coordinates(best,:), obj.coordinates );
                remove = ( dist <= radius );
                obj.H(remove) = [];
                obj.R(remove) = [];
                obj.coordinates(remove,:) = [];
            end
        end
            
    end
    
end         