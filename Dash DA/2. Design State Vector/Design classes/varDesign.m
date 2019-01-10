%% This is a custom structure that holds the design parameters for a single
% variable in a state vector.
classdef varDesign < handle
    
    % The values needed for each variable.
    properties
        % Grid file properties
        file; % File name
        dimID; % Dimensional ordering
        name;
        
        % Index properties
        indices;  % The allowed indices for state or ensemble dimensions
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
                fprintf( [sprintf('The %s dimension has already been set for this variable.', obj.dimID{d} ), ...
                                  newline, 'Continuing will overwrite the previous design for this dimension.', newline]);
                yn = input('Do you want to continue? (y/n): ', 's');

                while ~ismember(yn, {'y','n','Y','N','yes','no','YES','NO','Yes','No'})
                    yn = input( [newline, 'Please enter (y)es or (n)o.', newline, ...
                        sprintf('Do you want to overwrite the previous design for the %s dimension? (y/n): ', obj.dimID{d})],...
                        's');
                end

                if ismember( yn, {'n','N','no','NO','No'} )
                    error('Aborting new dimension design.');
                end
            end
        end
        
        %% Does an error check dimension design parameters. 
        function[] = errorCheck( obj, indices, d, takeMean, nanflag )
            
            % Check that takeMean is a scalar logical
            if ~isscalar(takeMean) || ~islogical(takeMean)
                error('takeMean must be a scalar logical.');
            elseif ~ismember( nanflag, {'omitnan','includenan'})
                error('Unrecognized NaN flag.');
            end
            
            % Get the size of the gridded data
            [~,~,gridSize] = metaGridfile( obj.file );
            
            % Get a label for indices for errors
            errStr = {'ensemble','sequence','mean'};
            
            % Note if state indices
            if isvector(indices) && ~iscell(indices)
                indices = {indices,[],[]};
                errStr{1} = 'state';
            end
            
            % Check that indices are formatted correctly
            if ~iscell(indices) || ~isvector(indices) || length(indices)~=3
                error('Unrecognized indices');
            end
  
            % For each set of indices
            for k = 1:numel(indices)
                
                % The first set of indices...
                if k==1
                    % Cannot be empty
                    if isempty( indices{k} )
                        error('The %s indices cannot be empty.', errStr{k});
                    % If 'all' or ':', convert to actual indices
                    elseif ischar(indices{k}) && isvector(indices{k}) && (strcmpi(indices{k},'all') || strcmp(indices{k},':') )
                        indices{k} = 1:gridSize(d);
                    % Numeric vector
                    elseif ~isnumeric(indices{k}) || ~isvector(indices{k})
                        error('The %s indices must be a numeric vector.', errStr{k});
                    end
                    
                    % Indices are 1 indexed, so use exact values.
                    currDex = indices{k};
                
                % Mean and sequence indices (only if not empty)
                elseif ~isempty( indices{k} )

                    % Check for numeric vector
                    if ~isnumeric(indices{k}) || ~isvector(indices{k})
                        error('The %s indices must be a numeric vector.', errStr{k});
                    % Must contain the 0 index
                    elseif ~ismember(0, indices{k})
                        error('The %s indices should contain the 0 index.', errStr{k});
                    end
                    
                    % Zero indexed. Increment to match data size
                    currDex = indices{k} + 1;
                end
                
                % Check that all are positive integers
                if any( currDex <= 0 ) || any( mod(currDex,1)~=0 )
                    error('Not all %s indices are positive integers.', errStr{k});
                    
                % Check that all are within the bounds of the gridFile
                elseif any( ~ismember( currDex, 1:gridSize(d) ) )
                    error('Some %s indices exceed the size of the gridded data.', errStr{k});
                end 
            end
        end
        
        %% Trims ensemble indices to only allow full sequences and means
        function[ensDex] = trimEnsemble( obj, ensDex, seqDex, meanDex, d )
            % Get the gridded data size
            [~,~,gridSize] = metaGridfile(obj.file);

            % Get the maximum number of additional indices for a full sequence
            seqSize = max(seqDex) + max(meanDex);

            % Trim the ensemble indices
            ensDex( ensDex > gridSize(d) - seqSize ) = [];
            
            % Ensure that there are remaining indices
            if isempty(ensDex)
                error('The sequence length is longer than the size of the gridded data.');
            end
        end
        
        %% Get all indices in a dimension
        function[ensDex] = getAllIndices( obj, d )
            [~,~,gridSize] = metaGridfile(obj.file);
            ensDex = 1:gridSize(d);
        end
        
        %% Design a state dimension
        function obj = stateDim( obj, dim, stateDex, takeMean, nanflag )
            
            % Get the dimension, check if overwriting
            d = obj.checkDim(dim);
            
            % Error check the inputs
            obj.errorCheck( stateDex, d, takeMean, nanflag );
            
            % Set the values
            obj.indices{d} = stateDex;
            obj.takeMean(d) = takeMean;
            obj.nanflag{d} = nanflag;
            
            % Note that the dimension has been set as a state dimension
            obj.isState(d) = true;
            obj.dimSet(d) = true;
        end
        
        %% Design an ensemble dimension
        function obj = ensembleDim( obj, dim, meta, ensDex, seqDex, meanDex, takeMean, nanflag )
            
            % If seqDex or meanDex are empty, set to defaults
            if isempty(seqDex)
                seqDex = 0;
            end
            if isempty(meanDex)
                meanDex = 0;
            end
            
            % Check that the dimension is recognized and if overwriting
            d = obj.checkDim(dim);
            
            % Convert 'all' or ':' to all indices
            if (ischar(ensDex) || isstring(ensDex)) && (strcmpi(ensDex, 'all') || strcmp(ensDex,':'))
                ensDex = obj.getAllIndices(d);
            end
            
            % Error check indices and mean arguments
            obj.errorCheck( {ensDex, seqDex, meanDex}, d, takeMean, nanflag );
            
            % Check the metadata
            if ~isvector(meta) || length(meta)~=length(seqDex)
                error('The metadata must be a vector with a value for each sequence member.');
            end
            
            % Convert a metadata array to a cell
            if ~iscell(meta)
                meta = num2cell( meta );
            end
            
            % Trim the ensemble indices so that only full sequences can be
            % selected
            ensDex = obj.trimEnsemble( ensDex, seqDex, meanDex, d);
                        
            % Set the values
            obj.indices{d} = ensDex;
            obj.seqDex{d} = seqDex;
            obj.meanDex{d} = meanDex;
            
            obj.ensMeta{d} = meta;
            obj.takeMean(d) = takeMean;
            obj.nanflag{d} = nanflag;
            
            % Note that the dimension has been set as an ensemble dimension
            obj.dimSet(d) = true;
            obj.isState(d) = false;
        end

        %% This is the constructor that builds the design object
        function obj = varDesign( file, dimID )
            
            % Set the file and var fields
            obj.file = file;
            obj.dimID = dimID;
            
            % Get the number of dimensions
            nDim = numel(dimID);
            
            % Preallocate dimensional quantities
            obj.indices = cell(nDim,1);
            obj.seqDex = cell(nDim,1);
            obj.meanDex = cell(nDim,1);
            
            obj.takeMean = false(nDim,1);
            obj.nanflag = cell(nDim,1);
            
            obj.dimSet = false(nDim,1);
            obj.isState = true(nDim,1);
            obj.ensMeta = cell(nDim,1);
            
            % Initialize all dimensions as state dimensions with all
            % indices selected            
            [~,~,gridSize] = metaGridfile(file);
            for d = 1:nDim
                obj.indices{d} = 1:gridSize(d);
            end
        end
    end
    
end