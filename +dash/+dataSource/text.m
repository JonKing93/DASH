classdef text < dash.dataSource.Interface
    %% dash.dataSource.text  Objects that read data from delimited text files
    % ----------
    % text Methods:
    %
    % General:
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
        %   obj = <strong>dash.dataSource.text</strong>(file)
        %   Creates an object to read data from a delimited text file
        %
        %   obj = <strong>dash.dataSource.text</strong>(..., opts)
        %   Reads data from the file using the provided ImportOptions object
        %
        %   obj = <strong>dash.dataSource.text</strong>(..., Name, Value)
        %   Specifies additional import options using name-value pair arguments.
        %   Supported Name-Value pairs are those in Matlab's "readmatrix"
        %   function. See the documentation page for "readmatrix" for
        %   details.
        % ----------
        %   Inputs:
        %       file (string scalar): The name of a delimited text file
        %       opts (ImportOptions): Additional options for importing data from the file
        %       Name,Value (name-value pair): Additional import options for reading data from the
        %           file. Supported pairs are those for the "readmatrix" function
        %
        %   Outputs:
        %       obj (scalar dash.dataSource.text object): The new text object
        %
        %   Throws:
        %       DASH:dataSource:text:invalidTextFile  if data cannot be imported
        %           from the file
        %
        % <a href="matlab:dash.doc('dash.dataSource.text.text')">Documentation Page</a>
            
            % Error check
            header = 'DASH:dataSource:text';
            dash.assert.strflag(file, 'file', header);
            obj.source = dash.assert.fileExists(file, [], header);
            
            % Check the data can be imported
            try
                X = readmatrix(obj.source, varargin{:});
            catch
                link = '<a href="matlab:doc readmatrix">readmatrix</a>';
                id = sprintf('%s:invalidTextFile', header);
                error(id, ['Could not import data from file:  %s\n',...
                    'It may not be a valid delimited-text file.\n',...
                    'Alternatively, you may need to adjust the import options\n',...
                    'for the %s function.'], obj.source, link);
            end
            
            % Get data type, size, and import options
            obj.dataType = class(X);
            obj.size = size(X);
            obj.importOptions = varargin;

            % Prohibit empty data sources
            if ismember(0, obj.size)
                id = 'DASH:dataSource:text:emptyArray';
                link = '<a href="matlab:doc readmatrix">readmatrix</a>';
                error(id, ['The %s function returns an empty array when\n',...
                    'applied to data source file:  %s\n',...
                    'You may need to adjust the import options for the %s function.'],...
                    link, obj.source, link);
            end
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
        % <a href="matlab:dash.doc('dash.dataSource.text.load')">Documentation Page</a>
 
            X = readmatrix(obj.source, obj.importOptions{:});
            X = X(indices{:});
            
        end
    end
end
                