%% Implements a PSM for UK37
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
        function[H] = sampleIndices( ~, ensMeta, sstName, obLat, obLon )
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
        
        % Check that the ensemble metadata has lat and lon fields
        if ~isfield(ensMeta,'lat') || ~isfield(ensMeta,'lon')
            error('Ensemble metadata must contain ''lat'' and ''lon'' fields.');
        end
        
        % Check that the name is a string
        if ~(isstring(sstName)&&isscalar(sstName)) && ~(ischar(sstName)&&isvector(sstName))
            error('sstName must be a string.');
        end
        
        % Get the name of the variable field
        [~,var] = getKnownIDs;
        
        % Find the indices of the variable
        sstDex = find( ismember( ensMeta.(var), sstName ) );
        
        % Get the metadata coords
        stateCoord = [cell2mat(ensMeta.lat(sstDex)), cell2mat(ensMeta.lon(sstDex))];
        
        % Get the closest lat-lon SST coordinate to the site
        H = samplingMatrix( [obLat, obLon], stateCoord, 'linear' );
        
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