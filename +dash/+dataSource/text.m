classdef text < dash.dataSource.Base
    %% dash.dataSource.text  Objects that read data from delimited text files
    % 
    %   text Properties:
    %     importOptions - Optional arguments to the "readmatrix.m" function
    %
    %   text Methods:
    %              text - Creates a new dash.dataSource.text object
    %              load - Load data from a delimited text file
    %
    %   <a href="matlab:dash.doc('dash.dataSource.text')">Online Documentation</a>
    
    properties
        importOptions;   % Optional arguments to the readmatrix.m function
    end
    
    methods
        function[obj] = text(file, varargin)
        %% dash.dataSource.text.text  Create a new object for reading data from delimited text files
        % ----------
        %   obj = dash.dataSource.text(file)
        %   Creates an object to read data from a delimited text file
        %
        %   obj = dash.dataSource.text(..., opts)
        %   Reads data from the file using the provided ImportOptions object
        %
        %   obj = dash.dataSource.text(..., Name, Value)
        %   Specifies additional import options using name-value pair arguments.
        %   Supported Name-Value pairs are those in Matlab's "readmatrix" function
        % ----------
        %   Inputs:
        %       file (string scalar): The name of a delimited text file
        %       opts (ImportOptions): Additional options for importing data from the file
        %       Name,Value: Additional import options for reading data from the
        %           file. Supported pairs are those for the "readmatrix" function
        %
        %   Outputs:
        %       obj: The new dash.dataSource.text object
        %
        %   Throws:
        %       DASH:dataSource:text:invalidTextFile  if data cannot be imported
        %           from the file
        %
        %   <a href="dash.doc('dash.dataSource.text.text')">Online Documentation</a>
            
            % Error check
            header = 'DASH:dataSource:text';
            dash.assert.strflag(file, 'file', header);
            obj.source = dash.assert.fileExists(file, header);
            
            % Check the data can be imported
            try
                X = readmatrix(obj.source, varargin{:});
            catch problem
                ME = MException(sprintf('%s:invalidTextFile', header), ...
                    'Could not import data from file "%s". It may not be a valid text file', obj.source);
                ME = addCause(ME, problem);
                throw(ME);
            end
            
            % Get data type, size, and import options
            obj.dataType = class(X);
            obj.size = size(X);
            obj.importOptions = varargin;
            
        end       
        function[X] = load(obj, indices)
        %% dash.dataSource.text.load  Load data from a delimited text file
        % ----------
        %   X = obj.load(indices)
        %   Loads data from a delimited text at the specified linear indices.
        % ----------
        %   Inputs:
        %       indices (cell vector, elements are vectors of linear indices): The
        %           indices of data elements to load from the file
        %
        %   Outputs:
        %       X (array): The loaded data
        %
        %   <a href="matlab:dash.doc('dash.dataSource.text.load')">Online Documentation</a>
 
            X = readmatrix(obj.source, obj.importOptions{:});
            X = X(indices{:});
            
        end
    end
end
                