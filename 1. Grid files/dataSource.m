classdef (Abstract) dataSource
    
    properties
        file;  % The file name
        var;   % The name of the variable in the file
        dataType;  % The type of data in the file.
        unmergedDims;  % The order of the dimensions in the file
        unmergedSize; % The size of the original data in the file
        merge; % A record of which dimenions should be merged
        mergedDims; % The order of the dimensions in the merged dataset
        mergedSize;   % The size of the data after merging dimensions
        fill; % The fill value for the data
        range;   % A valid range for the data
        convert;  % A linear transformation to apply to the data.
    end
    
    % Fields that must be set by the subclass constructor
    properties (Constant, Hidden)
        subclassResponsibilities = ["dataType", "unmergedSize"];
    end
    
    % Constructor and object methods.
    methods
        function[obj] = dataSource(file, var, dims, fill, range, convert)
            %% Does constructor operations essential for any data source.
            % Error check input strings. Checks source existence. Saves
            % values.
            
            % Error check strings, vectors
            dash.assertStrFlag(file, "file");
            dash.assertStrFlag(var, "var");
            if ~dash.isstrlist(dims)
                error('dims must be a string vector or cellstring vector.');
            end
            file = dash.checkFileExists(file);
            
            % Error check the post-processing values
            if ~isnumeric(fill) || ~isscalar(fill)
                error('fill must be a numeric scalar.');
            elseif ~isvector(range) || numel(range)~=2 || ~isnumeric(range)
                error('range must be a numeric vector with two elements.');
            elseif ~isreal(range) || any(isnan(range))
                error('range may not contain contain complex values or NaN.');
            elseif range(1) > range(2)
                error('The first element of range cannot be larger than the second element.');
            elseif ~isvector(range) || ~isnumeric(convert) || numel(convert)~=2
                error('convert must be a numeric vector with two elements.');
            elseif ~isreal(convert) || any(isnan(convert)) || any(isinf(convert))
                error('convert may not contain complex values, NaN, or Inf.');
            end
            
            % Save properties
            obj.file = file;
            obj.var = var;
            obj.unmergedDims = string(dims);        
            obj.fill = fill;
            obj.range = range;
            obj.convert = convert;
                        
        end        
        function[] = checkVariable( obj, fileVariables )
            infile = ismember(obj.var, fileVariables);
            if ~infile
                error('File %s does not contain a %s variable.', obj.file, obj.var);
            end
        end   
        function[X] = read( obj, mergedIndices )
        %% Reads values from a data source.
        %
        % X = obj.read( indices )
        %
        % ----- Inputs -----
        %
        % mergedIndices: A cell array. Each element contains the indices to read 
        %    for one dimension. Dimensions must be in the same order as the merged
        %    dimensions. Indices should be linear indices along the dimension.
        %
        % ----- Outputs -----
        %
        % X: The read values.
        
        
            % Preallocate
            nMerged = numel(obj.mergedDims);
            nUnmerged = numel(obj.unmergedDims);

            unmergedIndices = cell(nUnmerged, 1);    % The requested indices in the unmerged dimensions
            loadIndices = cell(nUnmerged, 1);        % The indices loaded from the source file
            loadSize = NaN(nUnmerged, 1);            % The size of the loaded data grid
            dataIndices = cell(nUnmerged, 1);        % The location of the requested data in the loaded data grid

            keepElements = cell(nMerged, 1);         % Which data elements to retain after the dimensions
                                                     % of the loaded data grid are merged.

            % Get unmerged indices by converting linear indices for merged dimensions
            % to subscript indices for unmerged dimensions.
            for d = 1:nMerged
                isdim = find( strcmp(obj.unmergedDims, obj.mergedDims(d)) );
                siz = obj.unmergedSize(isdim);
                [unmergedIndices{isdim}] = ind2sub(siz, mergedIndices{d});
            end

            % Currently, all data source (.mat and netCDF) can only load equally spaced
            % values. Get equally spaced indices to load from each source.
            for d = 1:nUnmerged
                uniqueIndices = unique(sort(unmergedIndices{d}));
                loadIndices{d} = dash.equallySpacedIndices(uniqueIndices);
                loadSize(d) = numel(loadIndices{d});

                % Determine the location of requested data elements in the loaded data
                % grid.
                start = loadIndices{d}(1);
                stride = loadIndices{d}(2) - loadIndices{d}(1);
                dataIndices{d} = ((unmergedIndices{d}-start) / stride) + 1;
            end

            % Convert unmerged data indices into linear indices for the merged dimensions.
            for d = 1:nMerged
                isdim = find( strcmp(obj.unmergedDims, obj.mergedDims(d)) );
                siz = loadSize(isdim);
                keepElements{d} = sub2ind(siz, dataIndices{isdim});
            end

            % Load the values from the data source
            X = obj.load( loadIndices );

            % Permute dimensions being merged to the front 
            for d = 1:nMerged
                order = 1:nUnmerged;
                isdim = strcmp(obj.unmergedDims, obj.mergedDims(d));
                order = [order(isdim), order(~isdim)];
                X = permute(X, order);

                % Reshape dimensions being merged into a single dimension. Use
                % singletons for secondary merged dimensions to preserve dimension order
                siz = size(X);
                nDim = numel(isdim);
                newSize = [prod(siz(1:nDim)), ones(1,nDim-1), siz(nDim+1:end)];
                X = reshape(X, newSize);

                % Unpermute
                [~, reorder] = sort(order);
                X = permute( X, reorder );

                % Convert data indices for unmerged dimensions to linear indices for
                % the merged dimension
                siz = loadSize(isdim);
                keepElements{d} = sub2ind(siz, dataIndices{isdim});
            end

            % Remove singletons resulting from the merge. Remove any unrequested data
            % elements that were loaded to fulfill equal spacing requirements
            X = squeeze(X);
            X = X(keepElements{:});
            
            % Convert fill value to NaN
            if ~isnan(obj.fill)
                X(X==obj.fill) = NaN;
            end
            
            % Convert values outside the valid range to NaN
            if ~isequal(obj.range, [-Inf Inf])
                valid = (X>=obj.range(1)) & (X<=obj.range(2));
                X(~valid) = NaN;
            end
            
            % Apply linear transformation
            if ~isequal(obj.convert, [1 0])
                X = obj.convert(1)*X + obj.convert(2);
            end
        end
    end
    
    % Create new dataSource subclass
    methods (Static)
        function[source] = new(type, file, var, dims, fill, range, convert)
            
            % Check the type is allowed
            if ~dash.isstrflag(type) || ~ismember(type, ["nc","mat"])
                error('type must be either the string "nc" or "mat".');
            end
            
            % Set defaults for optional values
            if ~exist('fill','var') || isempty(fill)
                fill = NaN;
            end
            if ~exist('range','var') || isempty(range)
                range = [-Inf Inf];
            end
            if ~exist('convert','var') || isempty(convert)
                convert = [1 0];
            end
            
            % Create the subclass dataSource object. This will error check
            % file, var, and dims and get the size of the raw unmerged data
            % in the source.
            if strcmp(type,'nc')
                source = ncSource(file, var, dims, fill, range, convert);
            elseif strcmp(type, 'mat')
                source = matSource(file, var, dims, fill, range, convert);
            end
            
            % Check that the subclass constructor set all fields for which
            % it is responsible
            fields = dataSource.subclassResponsibilities;
            for f = 1:numel(fields)
                if isempty( source.(fields(f)) )
                    error('The dataSource subclass constructor did not set the "%s" property.', fields(f));
                end
            end
            
            % Ensure all non-trailing singleton dimensions are named. Pad
            % the unmerged size for any named trailing singletons.
            nDims = numel(source.unmergedDims);
            minimumDims = max( [1, find(source.unmergedSize~=1,1,'last')] );            
            if nDims < minimumDims
                error('The first %.f dimensions of variable %s in file %s require names, but dims only contains %.f elements',minimumDims, obj.var, obj.file, numel(obj.dims) );
            elseif numel(source.unmergedSize) < nDims
                source.unmergedSize( end+1:nDims ) = 1;
            end
            
            % Get the merge map and merged data size
            source.mergedDims = unique(source.unmergedDims, 'stable');
            nUniqueDims = numel(source.mergedDims);
            source.merge = NaN(1,nDims);
            source.mergedSize = NaN(1,nUniqueDims);
            
            for d = 1:nUniqueDims
                isdim = find( strcmp(source.mergedDims(d), source.unmergedDims) );
                source.merge(isdim) = d;
                source.mergedSize(d) = prod( source.unmergedSize(isdim) );
            end
        end
    end
    
    % Subclass load values from data source
    methods (Abstract)
        X = load(obj, indices);
    end
    
end