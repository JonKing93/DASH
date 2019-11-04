classdef varDesign 
    % varDesign
    % This is a custom structure that holds design parameters for a single
    % variable in a state vector.
    %
    % This class should not be used by users. Instead, modify design
    % parameters via the "stateDesign" class.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    
    % The values needed for each variable.
    properties
        name;  % Variable name
        
        % Grid file properties
        file; % File name
        dimID; % Dimensional ordering
        dimSize; % Dimension size
        meta; % Metadata
        
        % State or Ensemble properties
        isState; % Whether a dimension is a state dimension.
        indices;  % The allowed indices for state or ensemble dimensions
        takeMean; % Toggle to take a mean
        nanflag;  % How to treat NaN

        % Indices
        seqDex;  % The indices used to get dimensional sequences
        seqMeta; % The metadata value for sequence members
        meanDex; % The indices used to take a mean
        
        % Ensemble draws
        drawDex;
        drawDim;
        undrawn;

        % Weighted means
        weightDims;    % The dimensions associated with each set of weights
        weights;        % The weights to use when taking a mean
    end
        
    methods
        %% This is the constructor that builds the design object
        function obj = varDesign( file, name )
            
            % Get the name. Convert to string for internal use.
            if ~isstrflag(name)
                error('Variable name must be a string scalar.');
            elseif ~isstrflag(name)
                error('File name must be a string scalar.');
            end
            obj.name = string(name);
            obj.file = string(file);
            
            % Get the grid file metadata
            [meta, dimID, dimSize] = gridFile.meta( file );
            
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
                
            % Get the number of dimensions
            nDim = numel(dimID);
            
            % Preallocate dimensional quantities
            obj.isState = true(nDim,1);
            obj.indices = cell(nDim,1);
            obj.takeMean = false(nDim,1);
            obj.nanflag = cell(nDim,1);
            obj.seqDex = cell(nDim,1);
            obj.seqMeta = cell(nDim,1);
            obj.meanDex = cell(nDim,1);
            
            obj.drawDex = [];
            obj.undrawn = [];
            
            for d = 1:nDim
                obj.indices{d} = (1:dimSize(d))';
            end
        end
    end

    % Utilities
    methods
        [scs, keep] = loadingIndices( obj );
    end
    
end