classdef (Abstract) fileSource < dataSource
    %% Used to read data from files. Check for file existence and stores 
    % file name.
    
    properties
        file;
    end
    
    methods
        function obj = fileSource(file)
            %% Creates a new fileSource object. Ensures the input file exists.
            %
            % obj = fileSource(file)
            %
            % ----- Inputs -----
            %
            % file: The name of the data source file. A string.
            %
            % ----- Outputs -----
            %
            % obj: The new fileSource object
            
            file = dash.assertStrFlag(file, 'file');
            obj.file = dash.checkFileExists(file);
        end
    end
    
end