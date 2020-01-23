classdef matGrid < gridData
    % Describes a data source that is a .mat file
    
    properties (SetAccess = private)
        filepath; % The filepath for the netcdf
        filename; % The name of the file. Used for error messages
        varName; % The name of the gridded data variable in the file
    end
    
    % Constructor
    methods
        function[obj] = matGrid( path, file, var, order, msize, umsize, merge, unmerge )
            obj.filepath = path;
            obj.filename = file;
            obj.varName = var;
            obj.dimOrder = order;
            obj.size = msize;
            obj.unmergedSize = umsize;
            obj.merge = merge;
            obj.mergeSet = unmerge;
        end
    end
    
    % Utilities
    methods
        [X, passVal] = read( obj, scs, ~, passVal );
    end
    
    % Static initialization
    methods (Static)
        [path, file, var, order, msize, umsize, merge, unmerge] = ...
        matGrid.initialize( file, var, dimOrder );
    end
    
end