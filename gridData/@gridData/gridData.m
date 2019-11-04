classdef (Abstract) gridData
    % Defines an interface for data structures that are placed in a
    % gridFile container object.
    
    properties
        dimOrder; % The order of dimensions in the gridded dataset
        size;  % The size of the gridded dataset
    end
    
    % Interface methods
    methods (Abstract = true)
        % Reads data from the data structure
        [X, passVal] = read( obj, scs, gridpath, passVal ); 
    end
    
    % Static Utilities
    methods (Static)
        % Removes trailing singletons from a size vector
        siz = squeezeSize( siz );
        
        % Returns a list of numeric types
        [types] = numericTypes
        
        % Get the size up to n dimensions
        [siz] = fullSize( siz, d )
    end
    
end
        