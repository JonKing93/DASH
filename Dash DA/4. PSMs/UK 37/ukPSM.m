%% Implements a PSM for UK 37
classdef ukPSM < PSM
    
    properties
        % The bayes posterior
        bayes;
    end
    
    properties (Constant)
        % Filename for the Bayes posterior
        bayesFile = 'bayes_posterior_v2.mat';
    end
    
    methods
        % Run the PSM
        function[uk] = runPSM( obj, M )
            uk = UK_forward_model( M, obj.bayes );
        end
        
        % Get the sample indices
        function[H] = getStateIndices( ~, ensMeta, sstName, obLat, obLon, time )
        %% Gets the sampling indices within a state vector for an
        % observation using the UK 37 forward model.
        %
        % H = sampleIndices( ensMeta, sstName, obLat, obLon )
        % 
        % ----- Inputs -----
        % 
        % ensMeta: The metadata structure for a state vector ensemble
        %
        % sstName: The name of the sst variable in the state vector.
        %
        % obLat: The latitude of the observation
        %
        % obLon: The longitude of the observation
        
        % Ensure there is a variable field and get the indices of the SST
        % variable. Also check for lat, lon metadata.
        sstDex = varCheck(ensMeta, sstName);
        dimCheck(ensMeta,'lat');
        dimCheck(ensMeta, 'lon');
        
        % Specify time requirements
        if exist('time','var')
            dimCheck(ensMeta, 'time');
            
            % Limit to the specified time value
            timeDex = 
        
        % Get lat and lon for the SST variable
        lat = cell2mat( ensMeta.lat(sstDex) );
        lon = cell2mat( ensMeta.lon(sstDex) );
                
        % Get the closest lat-lon SST coordinate to the site
        H = samplingMatrix( [obLat, obLon], [lat, lon], 'linear' );
        
        % Get the location within the entire state vector
        H = sstDex(H);
        
        end
        
        % Constructor 
        function obj = ukPSM
            % Pre-load the posterior
            obj.bayes = load(obj.bayesFile);
        end  
    end
    
end