classdef (Abstract) dataSource
    
    properties
        file;  % The file name
        var;   % The name of the variable in the file
        dataType;  % The type of data in the file.
        unmergedDims;  % The order of the dimensions in the file
        unmergedSize; % The size of the original data in the file
        merge; % A record of which dimenions should be merged
        mergedDims; % The dimensions of the merged dataset
        mergedSize;   % The size of the data after merging dimensions
    end
    
    % Fields that must be set by the subclass constructor
    properties (Constant, Hidden)
        subclassResponsibilities = ["dataType", "unmergedSize"];
    end
    
    methods
        % Constructor
        function[obj] = dataSource(file, var, dims)
            %% Does constructor operations essential for any data source.
            % Error check input strings. Checks source existence. Saves
            % values.
            
            % Error check strings, vectors
            if ~dash.isstrflag(file)
                error('The file name must be a string scalar or character row vector.');
            elseif ~dash.isstrflag(var)
                error('The variable name must be a string scalar or character row vector.');
            elseif ~dash.isstrlist(dims)
                error('dims must be a string vector or cellstring vector.');
            end
            
            % Check that the source file exists. Get the full name.
            haspath = false;
            if ~isempty(fileparts(file))
                haspath = true;
            end
            if haspath && ~exist(file,'file')
                error('The file %s does not exist.', file);
            elseif ~haspath && ~exist(file,'file')
                error('Could not find file %s. It may be misspelled or not on the active path.', file);
            end
            
            % Save file, var, dims
            obj.file = which(file);
            obj.var = var;
            obj.unmergedDims = string(dims);        
                        
        end
        
        % Check that a variable exists in the source
        function[] = checkVariable( obj, fileVariables )
            infile = ismember(obj.var, fileVariables);
            if ~infile
                error('File %s does not contain a %s variable.', obj.file, obj.var);
            end
        end
    end
    
    % Used to create a new data source from subclasses.
    methods (Static)
        function[source] = new(type, file, var, dims)
            
            % Check the type is allowed
            if ~dash.isstrflag(type) || ~ismember(type, ["nc","mat"])
                error('type must be either the string "nc" or "mat".');
            end
            
            % Create the subclass dataSource object. This will error check
            % file, var, and dims and get the size of the raw unmerged data
            % in the source.
            if strcmp(type,'nc')
                source = ncSource(file, var, dims);
            elseif strcmp(type, 'mat')
                source = matSource(file, var, dims);
            end
            
            % Check that the subclass constructor set all fields for which
            % it is responsible
            fields = dataSource.subclassResponsibilities;
            for f = 1:numel(fields)
                if isempty( source.(fields(f)) )
                    error('The dataSource subclass constructor did not set the "%s" property.', fields(f));
                end
            end
            
            % Find the last non-trailing singleton dimension. Ensure each
            % dimension to this point has a name. Pad the unmerged size
            % with ones for any named trailing singletons.
            nDims = numel(source.unmergedDims);
            minimumDims = find(source.unmergedSize~=1, 1, 'last');
            if isempty(minimumDims)
                minimumDims = 1;
            end
            
            if nDims < minimumDims
                error('The first %.f dimensions of variable %s in file %s require names, but dims only contains %.f elements',minimumDims, obj.var, obj.file, numel(obj.dims) );
            elseif numel(source.unmergedSize) < nDims
                source.unmergedSize( end+1:nDims ) = 1;
            end
            
            % Get the merge map and merged data size
            source.mergedDims = unique(source.unmergedDims, 'stable');
            nUnique = numel(source.mergedDims);
            source.merge = NaN(1,nDims);
            source.mergedSize = NaN(1,nUnique);
            
            for d = 1:nUnique
                isdim = find( strcmp(source.mergedDims(d), source.unmergedDims) );
                source.merge(isdim) = d;
                source.mergedSize(d) = prod( source.unmergedSize(isdim) );
            end
        end
    end
    
end