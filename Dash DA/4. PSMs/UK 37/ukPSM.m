%% Implements a PSM for UK 37
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRUCTOR:
%
% obj = ukPSM( obCoord )
% Creates a ukPSM for an observation at specific coordinates.
%
% obj = ukPSM( obCoord, bayesFile )
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
% H = getStateIndices( ensMeta, sstName )
% Gets state indices needed to run the PSM.
%
% H = getStateIndices( ..., 'lev', lev)
% H = getStateIndices( ..., 'time', time)
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
%
classdef ukPSM < PSM
    
    properties
        bayes; % The bayes prior
        bayesFile; % The bayes file used
        coord; % The object coordinates
    end
    
    properties (Constant, Hidden)
        % Filename for the Bayes posterior
        bayesDefault = 'bayes_posterior_v2.mat';
    end
    
    methods
        % Run the PSM
        function[uk] = runPSM( obj, M )
            
            % Run the forward model
            uk = UK_forward_model( M, obj.bayes );
            
            % Take the ensemble mean
            uk = mean(uk,2);
            
            % Convert to row
            uk = uk';
        end
        
        % Get the sample indices
        function[H] = getStateIndices( obj, ensMeta, sstName, varargin )

            % Parse inputs
            [time, lev] = parseInputs(varargin, {'time','lev'}, {[],[]}, {[],[]} );
            
            % Check the metadata fields are present
            dimCheck(ensMeta,'lat');
            dimCheck(ensMeta, 'lon');

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

            % Get the lat and lon coords
            lat = cell2mat(ensMeta.lat(sstVar));
            lon = cell2mat(ensMeta.lon(sstVar));

            % Get the closest site to the observation
            sstSite = samplingMatrix( obj.coord, [lat, lon], 'linear');

            % Get the location within the whole state vector
            H = sstVar(sstSite);
        end
        
        % Constructor 
        function obj = ukPSM( obCoord, varargin )
            
            % Check for alternate bayes file
            [file] = parseInputs(varargin, {'bayesFile'}, {[]}, {[]});
            
            % Load the bayes parameters
            if isempty(file)
                file = obj.bayesDefault;
            end
            obj.bayes = load(file);
            obj.bayesFile = file;
            
            % Set the coordinates
            obj.coord = obCoord;
        end  
    end
    
end