classdef ncSource < dataSource
    %% Implements a NetCDF data source
    
    properties
        nDims; % The number of defined dimensions for the variable in the netCDF
    end
    
    methods
        % Constructor
        function obj = ncSource(file, var, dims, fill, range, convert)
            
            % First call the data source constructor for initial error
            % checking and to save the input args
            obj@dataSource(file, var, dims, fill, range, convert);
            
            % Check the file is actually a NetCDF
            try
                info = ncinfo( obj.file );
            catch
                error('The file %s is not a valid NetCDF file.', obj.file );
            end
            
            % Check that the variable is in the file
            nVars = numel(info.Variables);
            fileVariables = cell(nVars,1);
            [fileVariables{:}] = deal( info.Variables.Name );
            obj.checkVariable( fileVariables );
            
            % Get the data type and size of the array
            [~,v] = ismember(obj.var, fileVariables);
            obj.dataType = info.Variables(v).Datatype;
            obj.unmergedSize = info.Variables(v).Size;
            obj.nDims = numel(info.Variables(v).Dimensions);
        end
        
        % Read from NetCDF
        function[X] = load(obj, indices)
            %% Loads data from a netCDF data source.
            %
            % X = obj.load(indices)
            %
            % ----- Inputs -----
            %
            % indices: A cell array. Each element contains the linear 
            %    indices to load for a dimension. Indices must be equally
            %    spaced and monotonically increasing. Dimensions must be in
            %    the order of the unmerged dimensions.
            
            % Preallocate
            start = NaN(1, obj.nDims);
            count = NaN(1, obj.nDims);
            stride = NaN(1, obj.nDims);
            
            % Convert indices to start, count, stride syntax
            for d = 1:numel(indices)
                start(d) = indices{d}(1);
                count(d) = numel(indices{d});
                stride(d) = indices{d}(2) - indices{d}(1);
            end
            
            % Load the data
            X = ncread( obj.file, obj.var, start, count, stride ); 
        end
    end
    
end