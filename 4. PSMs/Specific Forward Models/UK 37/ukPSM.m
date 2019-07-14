%% Implements a PSM for UK 37
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRUCTOR:
%
% obj = ukPSM( obCoord )
% Creates a ukPSM for an observation at specific coordinates.
%
% obj = ukPSM( ..., 'bayesFile', file )
% Uses a non-default bayes posterior file.
%
% ----- Inputs -----
%
% obCoord: [lat, lon] coordinate of an observation.
%
% bayesFile: The name of a bayes posterior file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE INDICES:
%
% getStateIndices( ensMeta, sstName )
% Gets state indices needed to run the PSM.
%
% getStateIndices( ..., dimName, dimPoints)
% Further restricts state indices to specific dimensional indices. See
% getClosestLatLonIndex.m for details.
%
% ----- Inputs -----
%
% ensMeta: Metadata for an ensemble
%
% sstName: The name of the SST variable.
%
% dimName: A dimension name, a string.
%
% dimPoints: The metadata associated with the specific dimensional points.
%            Each row is treated as one point of metadata.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

%% This defines the ukPSM class. ukPSM uses the PSM interface for Dash.
classdef ukPSM < PSM
    
    % The properties are the variables availabe to every instance of a
    % ukPSM object. The actual values of the properties can be different
    % for every ukPSM object.
    properties
        
        bayes;
        % This is the bayesian posterior distribution used to run the uk37
        % forward model.
        %
        % The original forward model loaded this distribution from a file each
        % time it ran. However, since the forward model ALWAYS uses 
        % the same value, I removed it from the forward model, and placed it in
        % the PSM object. This way, the PSM can load the posterior once, and
        % then use that distribution for every assimilation time step.
        %
        % This is mostly just limiting the number of times we need to load
        % from a file, but it has the added benefit that we can load from
        % different files to use different posteriors without altering any
        % of the code in the actual forward model.
        
        bayesFile = 'bayes_posterior_v2.mat';
        % This is the file that bayesian posterior is loaded from. The
        % default file is "bayes_posterior_v2.mat", but you can change this
        % file to use different posterior distributions.
        
        coord;
        % These are the lat-lon coordinates of a particular proxy site.
        % Longitude can be in either 0-360 or -180-180, either is fine.
        
    end
    
    %% The methods are the functions that each individual instance of a
    % ukPSM can run.
    methods
        
        
        % Constructor. This creates an instance of a PSM
        function obj = ukPSM( lat, lon, varargin )
            % Get optional inputs
            [file] = parseInputs(varargin, {'bayesFile'}, {[]}, {[]});
            
            % Get the file containing the posterior
            if ~isempty(file)
                if ~exist(file, 'file')
                    error('The specified bayes file cannot be found. It may be misspelled or not on the active path.');
                end
                obj.bayesFile = file;
            end
            
            % Load the posterior
            obj.bayes = load( obj.bayesFile );
            
            % Set the coordinates
            obj.coord = [lat lon];
        end  
        
        
        % Get State Indices
        % 
        % This determines the indices of elements in a state vector that
        % should be used to run the forward model for a particular uk37
        % site.
        function[] = getStateIndices( obj, ensMeta, sstName, varargin ) 
            sstName = string(sstName);
            obj.H = getClosestLatLonIndex( obj.coord, ensMeta, sstName, varargin{:} );
        end
        
        
        %% Review PSM
        %
        % This error check an instance of a ukPSM to ensure that it is
        % ready to be used wth dash.
        function[] = errorCheckPSM( obj )
            
            % This forward model only needs 1 variable - SST at the closest
            % site. So check that H is a scalar
            if ~isscalar( obj.H )
                error('H must be a scalar.');
            end
            
            % Check that the bayesian parameters exist
            if isempty(obj.bayes)
                error('The "bayes" property is empty.');
            end
        end        


        % This gets the model estimates by running the UK37 forward model.
        function[uk,R] = runForwardModel( obj, SST, ~, ~ )
            
            % Run the forward model. Output is 1500 possible estimates for
            % each ensemble member (1500 x nEns)
            uk = UK_forward_model( SST, obj.bayes );
            
            % Estimate R from the variance of the model for each ensemble
            % member. (scalar)
            R = mean( var(uk,[],1), 2);
            
            % Take the mean of the 1500 possible values for each ensemble
            % member as the final estimate. (1 x nEns)
            uk = mean(uk,1);
        end
    end
end