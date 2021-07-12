classdef (Abstract) Interface
    %% Implements an interface for objects that can extract information
    % from data sources. Concrete subclasses
    % implement functionality for different types of data sourcess. (For
    % example, netCDF and .mat files and opendap files).
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = protected)
        source; % The data source. A filename or opendap url
        var; % (For hdf data sources) The name of the variable.
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
    properties (Constant, Hidden)
        % Fields that must be set by the subclass constructor
        subclassResponsibilities = ["dataType", "unmergedSize"];
    end
    
    % Constructor methods, error checking, and interface
    methods
        function[obj] = Interface(source, sourceName, dims, fill, range, convert)
            %% Class constructor for a dataSource object. dataSource is an 
            % abstract class, so this provides constructor operations necessary
            % for any data source.
            %
            % obj = dataSource(dims, fill, range, convert)
            %
            % ----- Inputs -----
            %
            % dims: The order of the dimensions of the variable in the source file. A
            %    string or cellstring vector.
            %
            % fill: A fill value. Must be a scalar. When data is loaded from the file, 
            %    values matching fill are converted to NaN. 
            %
            % range: A valid range. A two element vector. The first element is the
            %    lower bound of the valid range. The second elements is the upper bound
            %    of the valid range. When data is loaded from the file, values outside
            %    of the range are converted to NaN.
            %
            % convert: Applies a linear transformation of form: Y = aX + b
            %    to loaded data. A two element vector. The first element specifies the
            %    multiplicative constant (a). The second element specifieds the
            %    additive constant (b).
            
            % Error check strings, vectors.
            source = dash.assert.strflag(source, sourceName);
            dims = dash.assert.strlist(dims, "dims");
            
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
            obj.source = source;
            obj.unmergedDims = dims;        
            obj.fill = fill;
            obj.range = range;
            obj.convert = convert;
                        
        end    
        
        function[obj] = checkFile(obj)
            %% Checks the data source is a file that exists
            obj.source = dash.assert.fileExists(obj.source);
        end
        
        function[obj] = setVariable(obj, var)
            %% For hdf data sources, sets the variable name
            obj.var = dash.assert.strflag(var, 'var');
        end
        
        function[] = checkVariableInSource(obj, sourceVariables)
            %% Checks that a variable is in a data source
            if ~ismember(obj.var, sourceVariables)
                error('The data source "%s" does not have a %s variable', obj.source, obj.var);
            end
        end
        
        % Interface to read values from a source for a gridfile
        function[X, obj] = read( obj, mergedIndices )
            %% Reads values from a data source.
            %
            % X = obj.read( mergedIndices )
            %
            % ----- Inputs -----
            %
            % mergedIndices: A cell array. Each element contains the indices to read 
            %    for one dimension. Dimensions must be in the same order as the merged
            %    dimensions. Indices should be linear indices along the dimension.
            %
            % ----- Outputs -----
            %
            % X: The values read from the data source file. Dimensions are in
            %    the order of the merged dimensions.

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

            % Currently, all data source (.mat and netCDF based) can only load equally spaced
            % values. Get equally spaced indices to load from each source.
            % (This may eventually be merged into hdfSource).
            for d = 1:nUnmerged
                uniqueIndices = unique(sort(unmergedIndices{d}));
                loadIndices{d} = dash.indices.equallySpaced(uniqueIndices);
                loadSize(d) = numel(loadIndices{d});

                % Determine the location of requested data elements in the loaded data
                % grid.
                start = loadIndices{d}(1);
                stride = 1;
                if numel(loadIndices{d})>1
                    stride = loadIndices{d}(2) - loadIndices{d}(1);
                end
                dataIndices{d} = ((unmergedIndices{d}-start) / stride) + 1;
            end

            % Load the values from the data source
            [X, obj] = obj.load( loadIndices );

            % Track which dimensions become singletons via merging
            remove = NaN(1, nUnmerged-nMerged);

            % Permute dimensions being merged to the front
            for d = 1:nMerged
                order = 1:nUnmerged;
                isdim = strcmp(obj.unmergedDims, obj.mergedDims(d));
                order = [order(isdim), order(~isdim)];
                isdim = find(isdim);
                if ~isequal(order,1)
                    X = permute(X, order);
                end

                % Reshape dimensions being merged into a single dimension. Use
                % singletons for secondary merged dimensions to preserve dimension order
                siz = size(X);
                nDim = numel(isdim);
                siz(end+1:nDim) = 1;

                newSize = [prod(siz(1:nDim)), ones(1,nDim-1), siz(nDim+1:end)];
                X = reshape(X, newSize);

                % Unpermute and note if any dimensions should be removed
                [~, reorder] = sort(order);
                if ~isequal(reorder, 1)
                    X = permute( X, reorder );
                end

                k = find(isnan(remove), 1, 'first');
                remove(k:k+nDim-2) = isdim(2:end);

                % Convert data indices for unmerged dimensions to linear indices for
                % the merged dimension
                siz = loadSize(isdim);
                if numel(isdim) > 1
                    keepElements{d} = sub2ind(siz, dataIndices{isdim});
                else
                    keepElements{d} = dataIndices{isdim};
                end
            end

            % Remove singletons resulting from the merge. 
            dimOrder = 1:nUnmerged;
            order = [dimOrder(~ismember(dimOrder,remove)), remove];
            if ~isequal(order, 1)
                X = permute(X, order);
            end

            % Remove any unrequested data elements that were loaded to
            % fulfill equal spacing requirements
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

    % Concrete subclasses must be able to load data from requested indices
    methods (Abstract)
        [X, obj] = load(obj, indices);
    end
    
end