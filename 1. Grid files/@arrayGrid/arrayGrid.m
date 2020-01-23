classdef arrayGrid < gridData
    % Describes a data source that is an actual array.
    
    properties (SetAccess = private)
        dataName; % The name of the data field in the gridFile
        m;        % A matfile for the grid
    end
    
    % Constructor
    methods
        function[obj] = arrayGrid( path, var, order, msize, umsize, merge, unmerge )
            obj.dataName = char(var);
            obj.dimOrder = order;
            obj.size = msize;
            obj.unmergedSize = umsize;
            obj.merge = merge;
            obj.mergeSet = unmerge;
            obj.m = matfile( path );
        end
    end
    
    % Interface utilities
    methods
        [X] = read(obj, scs );
    end
    
    % Static initialization
    methods (Static)
        [X, file, var, order, msize, umsize, merge, unmerge] = ...
            initialize( X, nSource, dimOrder );
    end
    
end