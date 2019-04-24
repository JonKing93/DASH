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
% obj = ukPSM( ..., 'convertT', convertT )
% Specifies a value to ADD to DA T values to convert to Celsius.
%
% ----- Inputs -----
%
% obCoord: [lat, lon] coordinate of an observation.
%
% bayesFile: The name of a bayes posterior file.
%
% convertT: A value to ADD to DA temperatures to convert to Celsius.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE INDICES:
%
% getStateIndices( ensMeta, sstName )
% Gets state indices needed to run the PSM.
%
% getStateIndices( ..., 'lev', lev)
% getStateIndices( ..., 'time', time)
% Further restricts state indices to specific time or lev points.
% (For SST variables with multiple levels or a time sequence.)
%
% ----- Inputs -----
%
% ensMeta: Metadata for an ensemble
%
% sstName: The name of the SST variable
%
% time: A time metadata value from which indices should be selected.
%
% lev: A lev metadata values from which indices should be selected.

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
        
        convertSST;
        % This is the temperature conversion that converts SSTs from the
        % model ensemble (in any particular unit), to Celsius -- the units
        % required for the forward model.
        %
        % (Currently only supports conversions from Celsius or Kelvin,
        % Farenheit is not supported.)
    end
    
    %% The methods are the functions that each individual instance of a
    % ukPSM can run.
    methods
        
        
        % Constructor. This creates an instance of a PSM
        function obj = ukPSM( coord, varargin )
            % Get optional inputs
            [file, convertT] = parseInputs(varargin, {'bayesFile','convertT'}, {[],0}, {[],[]});
            
            % Get the file containing the posterior
            if ~isempty(file)
                obj.bayesFile = file;
            end
            
            % Load the posterior
            obj.bayes = load( obj.bayesFile );
            
            % Set the coordinates and temperature conversion
            obj.coord = coord;
            obj.convertT = convertT;
            
        end  
        
        
        % Get State Indices
        % 
        % This determines the indices of elements in a state vector that
        % should be used to run the forward model for a particular uk37
        % site.
        function[] = getStateIndices( obj, ensMeta, sstName ) 
            obj.H = getClosestLatLonIndex( obj.coord, ensMeta, sstName );
        end
        
        
        %% Review PSM
        %
        % This error check an instance of a ukPSM to ensure that it is
        % ready to be used wth dash.
        function[] = reviewPSM( obj )
            
            % Check that H was set
            if isempty(obj.H)
                error('Did not set the state indices (H)');
            end
            
            % This forward model only needs 1 variable - SST at the closest
            % site. So check that H is a scalar
            if ~isscalar( obj.H )
                error('H must be a scalar.');
            end
            
            % Check that the bayes file and unit conversion exist
            if isempty(obj.bayes)
                error('The "bayes" property is empty.');
            elseif isempty( obj.convertSST )
                error('The "convertSST" property is empty.');
            elseif ~isscalar( obj.convertSST )
                error('The "convertSST" property should be a scalar.');
            end 
        end        
        
        
        % This converts units to celsius.
        function[SST] = convertUnits( obj, SST )
            SST = SST + obj.convertSST;
        end
            
        
        % Get the sample indices
        function[] = getStateIndices( obj, ensMeta, sstName, gridType, varargin )

            % Parse inputs
            [time, lev] = parseInputs(varargin, {'time','lev'}, {[],[]}, {[],[]} );
            
            % Get the variable's indices
            sstVar = varCheck(ensMeta, sstName);

            % If there is a time requirement, get the restricted indices.
            if ~isempty(time)
                dimCheck(ensMeta, 'time');
                sstTime = findincell( time, ensMeta.time(sstVar) );
                sstVar = sstVar(sstTime);
            end
            
            % If there is a lev requirement, get the restricted indices
            if ~isempty(lev)
                dimCheck(ensMeta, 'lev');
                sstLev = findincell( lev, ensMeta.lev(sstVar) );
                sstVar = sstVar(sstLev);
            end
            
            % For tripolar grids
            if strcmpi(gridType, 'tripolar')
                
                % Check for the metadata field
                dimCheck(ensMeta, 'tripole');
                
                % Get the lat, lon coordinates
                latlon = cell2mat( ensMeta.tripole(sstVar) );
                
            % For lat x lon grids
            elseif strcmpi(gridType, 'latxlon')
                
                % Check the metadata fields
                dimCheck(ensMeta, 'lat');
                dimCheck(ensMeta, 'lon');
                
                % Get the lat lon coordinates
                latlon = [cell2mat(ensMeta.lat(sstVar)), cell2mat(ensMeta.lon(sstVar))];
            else
                error('Unrecognized grid type');
            end

            % Get the closest site to the observation
            sstSite = samplingMatrix( obj.coord, latlon, 'linear');

            % Get the location within the whole state vector
            obj.H = sstVar(sstSite);
        end
        
        
        % This gets the model estimates by running the UK37 forward model.
        function[uk,R] = runPSM( obj, SST, ~, ~ )
            
            % Convert T to Celsius
            SST = obj.convertUnits( SST );
            
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