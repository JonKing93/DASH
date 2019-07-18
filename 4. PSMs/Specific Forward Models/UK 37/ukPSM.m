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
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

%% This defines the ukPSM class. ukPSM uses the PSM interface for Dash.
classdef ukPSM < PSM
    
    % The properties are the variables availabe to every instance of a
    % ukPSM object. The actual values of the properties can be different
    % for every ukPSM object.
    properties
        
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
            % obj.bayes = load( obj.bayesFile );
            
            % Set the coordinates
            obj.coord = [lat lon];
        end  
        
        
        % Get State Indices
        % 
        % This determines the indices of elements in a state vector that
        % should be used to run the forward model for a particular uk37
        % site.
        function[] = getStateIndices( obj, ensMeta, sstName, monthName, varargin ) 
            sstName = string(sstName);
             % Get the time dimension
            [~,~,~,~,~,~,timeID] = getDimIDs;
            obj.H = getClosestLatLonIndex( obj.coord, ensMeta, sstName, timeID, monthName, varargin{:} );
        end
        
        
        %% Review PSM
        %
        % This error check an instance of a ukPSM to ensure that it is
        % ready to be used wth dash.
        function[] = errorCheckPSM( obj )
            
            % This forward model only needs 1 variable - SST at the closest
            % site. So check that H is a scalar
            if ~isvector( obj.H ) || length(obj.H)~=12
                error('H is the wrong size.');
            end
            
            % Check that the bayesian parameters exist
            if isempty(obj.bayesFile)
                error('Missing Bayesian parameters file.');
            end
        end        


        % This gets the model estimates by running the UK37 forward model.
        function[uk,R] = runForwardModel( obj, M, ~, ~ )
            % Polygons for seasonal areas
            % Mediterranean polygon: Nov-May
            poly_m_lat=[36.25; 47.5; 47.5; 30; 30];
            poly_m_lon=[-5.5; 3; 45; 45; -5.5];
            % North Atlantic polygon: Aug-Oct
            poly_a_lat=[48; 70; 70; 62.5; 58.2; 48];
            poly_a_lon=[-55; -50; 20; 10; -4.5; -4.5];
            % North Pacific polygon: Jun-Aug
            poly_p_lat=[45; 70; 70; 52.5; 45];
            poly_p_lon=[135; 135; 250; 232; 180];
            
            if inpolygon(obj.coord(2),obj.coord(1),poly_m_lon,poly_m_lat)
                ind = [1 2 3 4 5 11 12];             
            elseif inpolygon(obj.coord(2),obj.coord(1),poly_a_lon,poly_a_lat)
                ind = [8 9 10];
            elseif   inpolygon(obj.coord(2),obj.coord(1),poly_p_lon,poly_p_lat)
                ind = [6 7 8];
            else
                ind = (1:12)';
            end
                SST = mean(M(ind',:),1);
            % Run the forward model. Output is 1500 possible estimates for
            % each ensemble member (1500 x nEns)
            uk = UK_forward( SST, obj.bayesFile );
            
            % Estimate R from the variance of the model for each ensemble
            % member. (scalar)
            R = mean( var(uk,[],2), 1);
            
            % Take the mean of the 1500 possible values for each ensemble
            % member as the final estimate. (1 x nEns)
            uk = mean(uk,2);
            % transpose for Ye
            uk = uk';
        end
    end
end