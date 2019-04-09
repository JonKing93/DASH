%% This is a custom structure that holds the design parameters for a single
% variable in a state vector.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef varDesign
    
    % The values needed for each variable.
    properties
        name;  % Variable name
        
        % Grid file properties
        file; % File name
        dimID; % Dimensional ordering
        dimSize; % Dimension size
        meta; % Metadata
        
        % State vs Ensemble properties
        isState; % Whether a dimension is a state dimension.
        ensMeta; % The metadata value for ensemble dimensions
        
        % Index properties
        indices;  % The allowed indices for state or ensemble dimensions
        seqDex;  % The indices used to get dimensional sequences
        meanDex; % The indices used to take a mean
        
        % Mean properties
        takeMean; % Toggle to take a mean
        nanflag;  % How to treat NaN
        
        % Coupler property
        overlap; % Whether an ensemble dimension permits non-duplicate overlapping sequences
    end
        
    methods
        %% This is the constructor that builds the design object
        function obj = varDesign( file, name )
            
            % Set the file field
            obj.file = file;
            
            % Get the dimID
            [meta, dimID, dimSize] = metaGridfile( file );
            
            % Ensure that the gridfile contains all known IDs
            allID = getDimIDs;
            if any(~ismember(allID, dimID))
                missing = allID( find(~ismember(allID, dimID),1) );
                error(['The gridfile %s is missing the %s dimension.\n',...
                       'The function getDimIDs.m may have been edited after the gridfile was created.'], file, missing);
            end
                
            % Set metadata
            obj.dimID = dimID;
            obj.dimSize = dimSize;
            obj.meta = meta;
            
            % Get the name. Convert to string
            if ischar(name) && isrow(name)
                name = string(name);
            elseif ~isstring(name) || ~isscalar(name)
                error('name must be a string.');
            end
            obj.name = name;
                
            % Get the number of dimensions
            nDim = numel(dimID);
            
            % Preallocate dimensional quantities
            obj.indices = cell(nDim,1);
            obj.seqDex = cell(nDim,1);
            obj.meanDex = cell(nDim,1);
            
            obj.takeMean = false(nDim,1);
            obj.nanflag = cell(nDim,1);
            
            obj.isState = true(nDim,1);
            obj.ensMeta = cell(nDim,1);
            
            obj.overlap = false;
            
            % Initialize all dimensions as state dimensions with all
            % indices selected. Set seq and mean to [].            
            for d = 1:nDim
                obj.indices{d} = 1:dimSize(d);
                obj.nanflag{d} = 'includenan';
                obj.seqDex{d} = [];
                obj.meanDex{d} = [];
            end
        end
    end
    
end