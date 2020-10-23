classdef (Abstract) ncSource < hdfSource
    %% Used to read data from source based on a NetCDF format. Includes 
    % local NetCDF files and OPeNDAP requests.
    
    properties
        nDims; % The number of dimensions recorded in the NetCDF
    end
    
    methods
        function obj = ncSource(source, var)
            %% Creates a new ncSource object.
            %
            % obj = ncSource(source, var)
            %
            % ----- Inputs -----
            %
            % source: A filename or opendap url. A string.
            %
            % var: The name of the variable in the source. A string
            %
            % ----- Outputs -----
            %
            % obj: The new ncSource object.
          
            % Superclass constructor. Check source and var are strings
            obj@hdfSource(source, var);
            
            % Check the file is actually a NetCDF
            try
                info = ncinfo(obj.source);
            catch
                error('The data source "%s" is not a valid NetCDF file.', obj.source);
            end
            
            % Check the variable is in the file. Get the list of variables.
            fileVariables = obj.checkVariableInSource(info);
            
            % Get the data type and size of the array
            [~,v] = ismember(obj.var, fileVariables);
            obj.dataType = info.Variables(v).Datatype;
            obj.unmergedSize = info.Variables(v).Size;
            obj.nDims = numel(info.Variables(v).Dimensions);
        end
        function[fileVariables] = checkVariableInSource(obj, info)
            %% Check the variable is in the NetCDF source. Returns the list
            % of variables in the NetCDF.
            %
            % fileVariables = obj.checkVariableInSource(info)
            %
            % ----- Inputs -----
            %
            % info: The structure provided via ncinfo
            %
            % ----- Outputs -----
            %
            % fileVariables: A list of variables in the NetCDF. A string
            %    vector or cellstring vector.
            
            nVars = numel(info.Variables);
            fileVariables = cell(nVars,1);
            [fileVariables{:}] = deal( info.Variables.Name );
            obj.checkVariable(fileVariables);
        end
        function[X, obj] = load(obj, indices)
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
            %
            % ----- Outputs -----
            %
            % X: The data located at the requested indices.
            
            % Preallocate
            start = NaN(1, obj.nDims);
            count = NaN(1, obj.nDims);
            stride = ones(1, obj.nDims);
            
            % Convert indices to start, count, stride syntax
            for d = 1:numel(indices)
                start(d) = indices{d}(1);
                count(d) = numel(indices{d});
                if numel(indices{d})>1
                    stride(d) = indices{d}(2) - indices{d}(1);
                end
            end
            
            % Load the data
            X = ncread( obj.source, obj.var, start, count, stride ); 
        end
    end
    
end
