classdef text < dash.dataSource.Interface
    %% dash.dataSource.text  Objects that read data from delimited text files
    % ----------
    % text Methods:
    %   text - Create a new dash.dataSource.text object
    %   load - Load data from a delimited text file
    %
    % <a href="matlab:dash.doc('dash.dataSource.text')">Documentation Page</a>
    
    properties
        importOptions;   % Optional arguments to the readmatrix.m function
    end
    
    methods
        function[obj] = text(file, varargin)
        %% dash.dataSource.text.text  Create a new dash.dataSource.text object
        % ----------
        %   obj = dash.dataSource.text(file)
        %   Creates an object to read data from a delimited text file
        %
        %   obj = dash.dataSource.text(..., opts)
        %   Reads data from the file using the provided ImportOptions object
        %
        %   obj = dash.dataSource.text(..., Name, Value)
        %   Specifies additional import options using name-value pair arguments.
        %   Supported Name-Value pairs are those in Matlab's "readmatrix"
        %   function. See the documentation page for "readmatrix" for
        %   details.
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
        %   <a href="dash.doc('dash.dataSource.text.text')">Documentation Page</a>
            
            % Error check
            header = 'DASH:dataSource:text';
            dash.assert.strflag(file, 'file', header);
            obj.source = dash.assert.fileExists(file, [], header);
            
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
        %   X = <strong>obj.load</strong>(indices)
        %   Loads data from a delimited text at the specified linear indices.
        % ----------
        %   Inputs:
        %       indices (cell vector [nDims] {vector, linear indices}):
        %           The indices of data elements along each dimension to load from 
        %           the text file. Should have one element per dimension of the variable.
        %           Each element holds a vector of linear indices.
        %
        %   Outputs:
        %       X (array): The loaded data
        %
        %   <a href="matlab:dash.doc('dash.dataSource.text.load')">Documentation Page</a>
 
            X = readmatrix(obj.source, obj.importOptions{:});
            X = X(indices{:});
            
        end
    end
end
                