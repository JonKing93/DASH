classdef gridFile
    % A container class that describes a gridded dataset.
    
    properties
        source; % A vector of data sources
        dimOrder; % The internal dimensional order used by the .grid file
        dimLimit; % The index limits of each data source in each dimension (nDim x 2 x nSource)
        metadata; % The metadata along each dimension and data attributes
        gridSize; % The total size of the gridded metadata.
    end
    
    methods
        
    end
    
    % Static methods
    methods (Static)
        
        % Creates a new .grid file
        new( filename, type, source, varargin );
        
        % Retrieves metadata from a .grid file
        [meta, dimID, gridSize] = meta( file );
        
        % Removes trailing singletons from the size of an array
        siz = squeezeSize( siz );
    end
        
end  
        
        