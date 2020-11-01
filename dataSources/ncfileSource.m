classdef ncfileSource < dataSource & fileSource & ncSource
    %% Reads data from a NetCDF file. (But not from OPeNDAP sources)
    
    methods
        function obj = ncfileSource(file, var, dims, fill, range, convert)
            %% Creates a new ncfileSource object. Checks the file exists,
            % is a valid netcdf, and contains the specified variable.
            %
            % obj = ncfileSource(file, var, dims, fill, range, convert)
            %
            % ----- Inputs -----
            %
            % file: The name of the netcdf file. A string.
            %
            % var: The name of the variable in the netcdf file. A string
            %
            % dims, fill, range, convert: See the documentation in dataSource
            
            % Superclass constructors
            obj = obj@dataSource(dims, fill, range, convert);
            obj = obj@fileSource(file);
            obj = obj@ncSource(file, var); 
        end
        function[X, obj] = load(obj, indices)
            %% Loads data from a netCDF file.
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
            
            [X, obj] = load@ncSource(obj, indices);
        end
    end
    
end