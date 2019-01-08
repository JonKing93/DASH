%% This is a custom structure that holds the design parameters for a single
% variable in a state vector.
classdef varDesign < handle
    
    % The values needed for each variable.
    properties
        % Grid file properties
        file; % File name
        dimID; % Dimensional ordering
        
        % Index properties
        fixDex;  % Indices for state dimensions
        ensDex;  % The allowed indices for drawing ensemble members
        seqDex;  % The indices used to get dimensional sequences
        meanDex; % The indices used to take a mean
        
        % Mean properties
        takeMean; % Toggle to take a mean
        nanflag;  % How to treat NaN
        
        % State vs Ensemble properties
        dimSet;  % Whether the dimension was previously set
        isState; % Whether a dimension is a state dimension.
        ensMeta; % The metadata value for ensemble dimensions
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

        %% This is the constructor that builds the design structure
        function obj = varDesign( file, dimID )
            
            % Set the file and var fields
            obj.file = file;
            obj.dimID = dimID;
            
            % Get the number of dimensions
            nDim = numel(dimID);
            
            % Preallocate dimensional quantities
            obj.fixDex = cell(nDim,1);
            obj.ensDex = cell(nDim,1);
            obj.seqDex = cell(nDim,1);
            obj.meanDex = cell(nDim,1);
            
            obj.takeMean = false(nDim,1);
            obj.nanflag = cell(nDim,1);
            
            obj.dimSet = false(nDim,1);
            obj.isState = true(nDim,1);
            obj.ensMeta = cell(nDim,1);
        end
    end
    
end