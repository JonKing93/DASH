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
        
        %% Queries a user if they want to overwrite a dimension
        function[d] = checkDim( obj, dim )
            
            % Get the dimension
            [isdim,d] = ismember( dim, obj.dimID );
            
            % Check that the dimension is recognized
            if ~isdim
                error('Unrecognized dimension.');
                
            % If the dimension is already set, query the user if they wish
            % to overwrite
            elseif obj.dimSet(d)
                fprinf( [sprintf('The %s dimension has already been set for this variable.', obj.dimID{d} ), ...
                                  newline, 'Continuing will overwrite the previous design for this dimension.', newline]);
                yn = input('Do you want to continue? (y/n): ', 's');

                while ~ismember(yn, {'y','n','Y','N','yes','no','YES','NO','Yes','No'})
                    yn = input( ['Please enter (y)es or (n)o.', newline, ...
                        sprintf('Do you want to overwrite the previous design for the %s dimension? (y/n): ', obj.dimID{d})],...
                        's');
                end

                if ismember( yn, {'n','N','no','NO','No'} )
                    error('Aborting new dimension design.');
                end
            end
        end
        
        %% Design a state dimension
        function obj = stateDim( obj, dim, fixDex, takeMean, nanflag )
            
            % Get the dimension, check if overwriting
            d = obj.checkDim(dim);
            
            % Set the values
            obj.fixDex{d} = fixDex;
            obj.takeMean(d) = takeMean;
            obj.nanflag{d} = nanflag;
            
            % Note that the dimension has been set as a state dimension
            obj.isState(d) = true;
            obj.dimSet(d) = true;
        end
        
        %% Design an ensemble dimension
        function obj = ensembleDim( obj, dim, meta, ensDex, seqDex, meanDex, takeMean, nanflag )
            
            % Check that the dimension is recognized and if overwriting
            d = obj.checkDim(dim);
            
            % Set the values
            obj.ensDex{d} = ensDex;
            obj.seqDex{d} = seqDex;
            obj.meanDex{d} = meanDex;
            
            obj.ensMeta{d} = meta;
            obj.takeMean(d) = takeMean;
            obj.nanflag{d} = nanflag;
            
            % Note that the dimension has been set as an ensemble dimension
            obj.dimSet(d) = true;
            obj.isState(d) = false;
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