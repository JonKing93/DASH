%% This is a custom structure that holds the design parameters for a single
% variable in a state vector.
classdef varDesign < handle
    
    % The values needed for each variable.
    properties
        % Dimension independent
        file; % The name of the gridfile
        var;  % The name of the variable
        dimID; % The dimensional ordering
        
        % Dimension specific
        takeMean;    % Whether to take a mean along a dimension
        fixDex;     % The (fixed) indices of state dimensions
        seqDex;   % Sequence indices for ensemble dimensions
        meanDex;  % Mean indices for ensemble dimensions
        nanflags; % Nan flag for each mean
        meanMeta; % Metadata value for means
        replace;  % Replacement argument for ensemble sampling
        nofill;   % NaN blocking options
        dimType;  % State vs Ensemble dimension and whether the value was previously set.
    end
        
    methods
        
        % This is the constructor that builds the design structure
        function obj = varDesign( file, varName, dimID )
            
            % Set the file and var fields
            obj.file = file;
            obj.var = varName;
            obj.dimID = dimID;
            
            % Get the number of dimensions
            nDim = numel(dimID);
            
            % Preallocate dimensional quantities
            obj.takeMean = false(nDim,1);
            obj.fixDex = cell(nDim,1);
            obj.seqDex = cell(nDim,1);
            obj.meanDex = cell(nDim,1);
            obj.nanflags = cell(nDim,1);
            obj.meanMeta = cell(nDim,1);
            obj.replace = false(nDim,1);
            obj.nofill = cell(nDim,1);
            obj.dimType = zeros(nDim,1);
        end
    end
    
end