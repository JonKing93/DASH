classdef arrayGrid < gridData
    % Describes a data source that is an actual array.
    
    properties (SetAccess = private)
        dataName; % The name of the data field in the gridFile
    end
    
    % Constructor
    methods
        function[obj, X] = arrayGrid( X, nSource, dimOrder )
            % Creates a new arrayGrid object. 
            
            % Ensure the data is numeric or logical
            if ~isnumeric(X) && ~islogical(X)
                error('X must be a numeric or logical array.');
            end
            
            % Get the data name
            obj.dataName = sprintf('data%.f', nSource+1);
            
            % Process dimensions, note merging
            [obj.unmergedSize, obj.size, obj.dimOrder, obj.merge, obj.mergeSet] = ...
                gridData.processSourceDims( dimOrder, size(X) );
            
            % Merge the data dimensions
            X = obj.mergeDims( X, obj.merge );
            obj.unmergedSize = obj.size;
            obj.merge = NaN( 1, numel(obj.size) );
            obj.mergeSet = NaN(1, numel(obj.size) );
        end
    end
    
    % Interface utilities
    methods
        [X, passVal] = read(obj, scs, gridpath, passVal );
    end
    
    % Static initialization
    methods (Static)
        [X, file, var, order, msize, umsize, merge, unmerge] = ...
            initialize( X, nSource, dimOrder );
    end
    
end