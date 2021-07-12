classdef nc < dash.dataSource.Interface
    %% Used to read data from source based on a NetCDF format. Includes 
    % local NetCDF files and OPeNDAP requests.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = protected)
        nDims; % The number of dimensions recorded in the NetCDF
    end
    
    methods
        function obj = nc(source, sourceName, var, dims, fill, range, convert)
            
            % Constructor and error checking
            obj@dash.dataSource.Interface(source, sourceName, dims, fill, range, convert);
            obj = obj.setVariable(var);
            if strcmp(sourceName, 'file')
                obj = obj.checkFile;
            end
            
            % Check the source is actually a NetCDF
            try
                info = ncinfo(obj.source);
            catch
                error('The data source "%s" is not a valid NetCDF file.', obj.source);
            end
            
            % Check the variable is in the file. Get the list of variables.
            nVars = numel(info.Variables);
            fileVariables = cell(nVars,1);
            [fileVariables{:}] = deal( info.Variables.Name );
            obj.checkVariableInSource(fileVariables);
            
            % Get the data type and size of the array
            [~,v] = ismember(obj.var, fileVariables);
            obj.dataType = info.Variables(v).Datatype;
            obj.unmergedSize = info.Variables(v).Size;
            obj.nDims = numel(info.Variables(v).Dimensions);
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
