%% This is a class to implement the UK 37 forward model for DA.
% 
% obj = ukPSM( sstName )
% Creates a ukPSM using the default posterior variables.
%
% obj = ukPSM( sstName, postFile )
% Creates a ukPSM using a user-specified posterior file.
%
% ukPSM.runPSM( sst )
% Runs the PSM.
%
% ukPSM.getStateIndices( siteMeta, stateMeta )
% Determines the state variables needed to run the model for a site.
%
% ----- Inputs -----
%
% sstName: The string used to mark SST variables in state variable
%      metadata.
%
% postFile: The name of a bayes posterior distribution .mat file.
%      Must contain the following variables.
%           b_draws_final
%           knots
%           tau2_draws_final
%
% sst: Sea surface temperatures.
%      *** Note: The default posterior calibration is seasonal for the
%      North Pacific (Jun-Aug), North Atlantic (Aug-Oct), and Mediterranean
%      (Nov-May). Use seasonal SSTs for these regions.
%
% siteMeta: Must include the following fields
%       lat: Latitude of the site
%       lon: Longitude of the site
%
% stateMeta: Must include the following fields
%       lat: Latitude of each state variable
%       lon: Longitude of each state variable
%       var: Variable name of each state variable

classdef ukPSM < PSM
    
    %%%%% USER SPECIFIED %%%%%
    % This is the default filename for the bayes posterior.
    properties (Constant)
        defaultPostFile = 'bayes_posterior_ukPSM.mat';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Some useful variables...
    properties
        % Store bayes posterior variables so they are not reloaded each
        % time
        b_draws_final;
        knots;
        tau2_draws_final;
        
        % Record the name of the posterior file to facilitate replication.
        postFile;
        
        % Store the name of the SST variable in state variable metadata.
        sstName;
    end
    
    % Some useful functions...
    methods
        
        % Constructor for the ukPSM.
        function obj = ukPSM( sstName, postFile )
            
            % Record the name of the SST variable
            obj.sstName = sstName;

            % Get the posterior file. Use default if unspecified.
            if ~exist('postFile','var') || isempty(postFile)
                postFile = ukPSM.defaultPostFile;
            end
            obj.postFile = postFile;

            % Load the posterior variables
            p = load( obj.postFile );

            obj.b_draws_final = p.b_draws_final;
            obj.knots = p.knots;
            obj.tau2_draws_final = p.tau2_draws_final;
        end
        
        % Runs the PSM.
        function[Ye] = runPSM(obj, sst, ~, ~, ~)
            Ye = UK_forward_model( sst, obj.b_draws_final, obj.knots, obj.tau2_draws_final );
        end
        
        % Determines the state indices needed to run the PSM for a site
        function[H] = getStateIndices( obj, siteMeta, stateMeta )
        
            % Get the lat-lon coordinates of state variables
            stateCoord = [stateMeta.lat, stateMeta.lon];
            
            % Determine the state variables that are SSTs
            sstDex = strcmpi( stateMeta.var, obj.sstName );
            
            % Find the closest state variable to the site that is an SST
            stateCoord( ~sstDex, : ) = NaN;
            H = samplingMatrix( [siteMeta.lat, siteMeta.lon], stateCoord, 'linear' );
        end
    end
end