classdef arrayGrid < gridData
    % Describes a data source that is an actual array.
    
    properties (SetAccess = private)
        gridFile; % The gridfile containing the array
        dataName; % The name of the data field in the gridFile
    end
    
    % Constructor
    methods
        function[obj] = arrayGrid( X, gridFile, dataName, dimOrder )
            % Creates a new arrayGrid object. 
            
            % Ensure the data is numeric
            if ~isnumeric(X)
                error('X must be a numeric array.');
            end
            
            % These two are directly provided by the call from the gridFile
            % object. No error checking.
            obj.gridFile = gridFile;
            obj.dataName = dataName;
            
            % Get the data size. Remove trailing singletons
            siz = size( X );
            obj.size = gridData.squeezeSize( siz );
            
            % Check there is a dimension for all non-trailing singletons
            if ~isstrlist( dimOrder )
                error('dimOrder must be a vector that is a string, cellstring, or character row');
            end
            dimOrder = string(dimOrder);
            nExtra = numel(dimOrder) - numel(siz);
            if nExtra < 0
                error('There are %.f named dimensions, but the array has more (%.f) dimensions.', numel(dimOrder), numel(siz) );
            else
                obj.size = [obj.size, ones(1,nExtra)];
            end 
            obj.dimOrder = dimOrder;
        end
    end
    
    % Utilities
    methods
        X = read( start, count, stride );
    end
    
end