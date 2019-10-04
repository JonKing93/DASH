classdef ukPSM < PSM
    % ukPSM
    % Implements proxy model for Uk'37
    %
    % ukPSM Methods:
    %   getStateIndices - Finds state vector elements needed to run the PSM

    properties
        bayesFile = 'bayes_posterior_v2.mat';   % The file with the Bayesian posterior
        coord;    % Lat lon coordinates of the proxy site
    end
    
    % Constructor
    methods
        function obj = ukPSM( lat, lon, varargin )
            % Creates a new ukPSM object
            %
            % obj = ukPSM( lat, lon )
            % Creates a ukPSM at the specified coordinates
            %
            % obj = ukPSM( lat, lon, 'bayesFile', file )
            % Specifies a file to use for loading the Bayesian posterior.
            % Default is 'bayes_posterior_v2.mat'
            %
            % ----- Inputs -----
            %
            % lat: Site latitude. A scalar
            %
            % lon: SIte longitude. A scalar
            %
            % file: The name of the file with a bayesian posterior.
            
            % Get the posterior file
            [file] = parseInputs( varargin, {'bayesFile'}, {[]}, {[]} );
            if ~isempty(file)
                if ~exist(file, 'file')
                    error('The specified bayes file cannot be found. It may be misspelled or not on the active path.');
                end
                obj.bayesFile = file;
            end
            
            % Set the coordinates
            obj.coord = [lat, lon];
        end
    end
    
    % PSM methods
    methods
        
        % State indices
        getStateIndices( obj, ensMeta, sstName, monthMeta, varargin );
        
        % Error checking
        errorCheckPSM( obj );
        
        % Run the forward model
        [uk, R] = runForwardModel( obj, M );
        
    end
        
    % The actual forward model
    methods (Static)
        uk = UK_forward_model( ssts, bayes );
    end
            
end     