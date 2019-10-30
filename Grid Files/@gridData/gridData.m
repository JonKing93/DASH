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
        X = read( obj, start, count, stride ); 
    end
    
    % Static Utilities
    methods (Static)
        siz = squeezeSize( siz );
    end
    
end
        