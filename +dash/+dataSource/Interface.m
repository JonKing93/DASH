classdef (Abstract) Interface
    %% dash.dataSource.Interface  Interface for objects that read data from a source file
    % ----------
    %   dash.dataSource.Interface is an abstract interface. It requires concrete
    %   subclasses to implement a "load" method that reads data from a 
    %   source file.
    % ----------
    % Interface methods:
    %   load - Load data from a source file
    %
    % <a href="matlab:dash.doc('dash.dataSource.Interface')">Documentation Page</a>
    
    properties (SetAccess = protected)
        source;     % The data source. A filename or opendap url
        dataType;   % The type of data stored in the source
        size;       % The size of the data in the source
    end
       
    methods (Abstract)
        
        % dash.dataSource.Interface.load  Load data from a source file.
        % ----------
        %   X = <strong>obj.load</strong>(indices)
        %   Loads data from a source at the specified LINEAR indices.
        % ----------
        %   Inputs:
        %       indices (cell vector [nDims] {vector, linear indices}):
        %           The indices of data elements along each dimension to load from 
        %           the source file. Should have one element per dimension of the variable.
        %           Each element holds a vector of strided linear indices.
        %
        %   Outputs:
        %       X (array): The loaded dataset
        %
        %   <a href="matlab:dash.doc('dash.dataSource.Interface.load')">Documentation Page</a>
        X = load(obj, indices)
        
    end
end