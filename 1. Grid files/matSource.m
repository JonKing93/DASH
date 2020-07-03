classdef matSource < dataSource
    %% Implements a .mat file data source
    
    methods
        % Constructor
        function obj = matSource(file, var, dims)
            % First call the data source constructor for initial error
            % checking and to save the input args
            obj@dataSource(file, var, dims);
            
            % Check that the file is a matfile
            try
                m = matfile(file);
            catch
                error('The file %s is not a valid .mat file.', file);
            end
            
            % Check the variable is in the file
            fileVariables = string(who(m));
            obj.checkVariable( fileVariables );
            
            % Get the data type and size of the array
            info = whos(m, obj.var);
            obj.dataType = info.class;
            obj.unmergedSize = info.size;
        end
        
        % Read data from a .mat file
        function[X] = load( obj, indices )
            %% Loads data from a .mat data source.
            %
            % X = obj.readSource(indices)
            %
            % ----- Inputs -----
            %
            % indices: A cell array. Each element contains the linear 
            %    indices to load for a dimension. Indices must be equally
            %    spaced and monotonically increasing. Dimensions must be in
            %    the order of the unmerged dimensions.
            
            X = obj.m.(obj.var)(indices{:});
        end
    end
    
end
            
            