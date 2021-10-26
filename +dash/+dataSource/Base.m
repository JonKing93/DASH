classdef (Abstract) Base
    %% dash.dataSource.Base  Superclass for objects that read data from a source
    % ----------
    %   dash.dataSource.Base is abstract and requires concrete subclasses
    %   to implement a "load" method for reading data from a source.
    % ----------
    %   Base Properties:
    %       source - The data source. A filename or opendap url
    %     dataType - The type of data stored in the source
    %         size - The size of the data in the source
    %
    %   Abstract Base Methods:
    %     load - Loads data from a source
    %
    %   <a href="matlab:dash.doc('dash.dataSource.Base')">Online Documentation</a>
    
    properties (SetAccess = protected)
        source;     % The data source. A filename or opendap url
        dataType;   % The type of data stored in the source
        size;       % The size of the data in the source
    end
       
    methods (Abstract)
        
        % dash.dataSource.Base/load  Loads data from a source
        % ----------
        %   X = <strong>obj.load</strong>(indices)
        %   Loads data from a source at the specified LINEAR indices.
        % ----------
        %   Inputs:
        %       indices (cell vector, elements are vectors of linear indices):
        %           The indices of the data elements to load from the source
        %
        %   Outputs:
        %       X (array): The loaded dataset
        %
        %   <a href="matlab:dash.doc('dash.dataSource.Base.load')">Online Documentation</a>
        X = load(obj, indices)
        
    end
end