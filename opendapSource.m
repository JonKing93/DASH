classdef opendapSource < ncSource
    %% Implements a data source that reads data from OPeNDAP NetCDFs
    
    properties
        X; % The loaded and saved dataset
        attemptFullLoad; % Whether to attempt to load the entire dataset
        saved; % Whether the dataset is currently saved
    end
    
    methods
        function obj = opendapSource(file, var, dims, fill, range, convert)
            %% Creates a new opendapSource object
            %
            % obj = opendapSource(file, var, dims, fill, range, convert)
            %
            % ----- Inputs -----
            %
            % See the documentation in dataSource.new
            %
            % ----- Outputs -----
            %
            % obj: A new opendapSource object
            
            % Use the ncSource constructor
            obj@ncSource(file, var, dims, fill, range, convert);
            
            % Track status of loading the entire dataset
            obj.attemptFullLoad = true;
            obj.saved = false;
        end          
        function[X, obj] = load(obj, indices)
            %% Loads data from an OPeNDAP data source
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
            
            % Attempt to load the entire dataset
            if obj.attemptFullLoad
                try
                    obj.X = ncread(obj.file, obj.var);
                    obj.saved = true;
                catch
                end
                obj.attemptFullLoad = false;
            end
            
            % If the dataset is saved, load values directly
            if obj.saved
                X = obj.X(indices{:});
                
            % Otherwise, use the usual ncread approach
            else
                [X, obj] = load@ncSource(obj, indices);
            end
        end 
    end
end   