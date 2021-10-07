classdef (Abstract) dataSource
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
    
    % Fields that must be set by the subclass constructor
    properties (Constant, Hidden)
        subclassResponsibilities = ["dataType", "unmergedSize"];
    end
    
    % Constructor and interface for subclass constructors
    methods
        function[obj] = dataSource(source, sourceName, dims, fill, range, convert)
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
    end
    methods (Static)
        source = new(type, file, var, dims, fill, range, convert)
    end
    
    % Object utilities
    methods
        function[] = checkVariableInSource(obj, sourceVariables)
            %% Checks that a variable is in a data source
            if ~ismember(obj.var, sourceVariables)
                error('The data source "%s" does not have a %s variable', obj.source, obj.var);
            end
        end
        [X, obj] = read(obj, mergedIndices);
    end

    % Concrete subclasses must be able to load data from requested indices
    methods (Abstract)
        [X, obj] = load(obj, indices);
    end
    
end