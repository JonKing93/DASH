%% This is a custom structure that holds the design parameters for a single
% variable in a state vector.
classdef varDesign < handle
    
    % The values needed for each variable.
    properties
        % Dimension independent
        file; % The name of the gridfile
        dimID; % The dimensional ordering
        
        % Dimension specific
        takeMean;    % Whether to take a mean along a dimension
        fixDex;     % The (fixed) indices of state dimensions
        ensDex;   % The allowed indices for ensemble draws
        seqDex;   % Sequence indices for ensemble dimensions
        meanDex;  % Mean indices for ensemble dimensions
        nanflags; % Nan flag for each mean
        meanMeta; % Metadata value for means
        replace;  % Replacement argument for ensemble sampling
        nofill;   % NaN blocking options
        dimSet;  % State vs Ensemble dimension and whether the value was previously set.
    end
        
    methods
        
        % This adds data for a dimension to the variable design
        function obj = specifyDim( dim, takeMean, meanMeta, nanflag, index,...
                                   seqDex, meanDex, replace, nofill)
            
            % Get the index of the dimension
            d = find( strcmpi( dim, obj.dimID ) );
            if isempty(d)
                error('The variable does not contain the input dimension.');
            end
            
            % Check if this dimension has already been set
            % !!!!!!! Need to write this
            if obj.dimSet(d) == 1
                userQuery;
            end
            
            % Add the new values for means
            obj.takeMean(d) = takeMean;
            obj.meanMeta{d} = meanMeta;
            obj.nanflags{d} = nanflag;
            
            % Add values
            if isState
                obj.fixDex{d} = index;
            else
                obj.ensDex{d} = index;
                obj.seqDex{d} = seqDex;
                obj.meanDex{d} = meanDex;
                obj.replace(d) = replace;
                obj.noFill{d} = noFill;
            end
            obj.dimSet = 1;
        end

        % This is the constructor that builds the design structure
        function obj = varDesign( file, dimID )
            
            % Set the file and var fields
            obj.file = file;
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
            obj.ensDex = cell(nDim,1);
        end
    end
    
end