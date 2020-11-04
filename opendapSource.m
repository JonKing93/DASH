classdef opendapSource < ncSource
    %% Reads data accessed via an OPeNDAP url. Attempts to load and save 
    % the entire variable when using repeated loads to increase speed.
    
    properties
        X; % The loaded and saved dataset
        attemptFullLoad; % Whether to attempt to load the entire dataset
        saved; % Whether the dataset is currently saved
    end
    
    methods
        function obj = opendapSource(url, var, dims, fill, range, convert)
            %% Creates a new opendapSource. Checks the url links to a valid
            % netcdf file that contains the specified variable.
            %
            % obj = opendapSource(url, var, dims, fill, range, convert)
            %
            % ----- Inputs -----
            %
            % url: The OPeNDAP url. A string.
            %
            % var: The name of the variable in the OPeNDAP NetCDF. A string
            %
            % dims, fill, range, convert: See the documentation in dataSource
            %
            % ----- Outputs -----
            %
            % obj: The new opendapSource object
            
            % Superclass constructors
            obj@ncSource(url, false, var, dims, fill, range, convert);
            
            % Track status of loading the entire dataset
            obj.attemptFullLoad = true;
            obj.saved = false;
        end
        function[X, obj] = load(obj, indices)
            %% Load data from an OPeNDAP data source.
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
            
            % Attempt to load the entire dataset once
            if obj.attemptFullLoad
                try
                    obj.X = ncread(obj.source, obj.var);
                    obj.saved = true;
                catch
                end
                obj.attemptFullLoad = false;
            end
            
            % If saved, load directly. Otherwise, use ncread
            if obj.saved
                X = obj.X(indices{:});
            else
                [X, obj] = load@ncSource(obj, indices);
            end
        end
    end
    
end