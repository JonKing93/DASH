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
        function[X] = readSource( obj, start, count, stride )
            %% Reads data from a .mat data source.
            %
            % X = obj.readSource(start, count, stride)
            
            % Convert start, count, and stride to indices
            nDim = size(start,2);
            indices = cell(1,nDim);
            for d = 1:nDim
                indices{d} = start(d):stride(d):start(1)+stride(d)*(count(d)-1);
            end
            
            % Read the data
            X = obj.m.(obj.var)(indices{:});
        end
    end
    
end
            
            