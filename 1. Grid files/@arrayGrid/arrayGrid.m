classdef arrayGrid < gridData
    % Describes a data source that is an actual array.
    
    properties (SetAccess = private)
        dataName; % The name of the data field in the gridFile
    end
    
    % Constructor
    methods
        function[obj] = arrayGrid( var, order, msize, umsize, merge, unmerge )
            obj.dataName = var;
            obj.dimOrder = order;
            obj.size = msize;
            obj.unmergedSize = umsize;
            obj.merge = merge;
            obj.mergeSet = unmerge;
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