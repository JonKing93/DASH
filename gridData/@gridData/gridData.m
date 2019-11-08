classdef (Abstract) gridData
    % Defines an interface for data structures that are placed in a
    % gridFile container object.
    
    properties
        dimOrder; % The order of dimensions in the gridded dataset
        size;  % The size of the gridded dataset
        mergeSet;  % An index for the set of merged dimensions
        unmergedSize;   % Size without any squashed dimensions
        merge; % Indicates which dimensions should be merged
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
        
        % Initial processing of merged dimensions
        [umSize, mSize, uniqDim, merge, mergeSet] = processSourceDims( dimOrder, iSize )
        
        % Actually merge data dimension
        [X] = mergeDims( X, merge )
    end
    
    methods
        % Adjust SCS and keep for merged
        [fullSCS, keep] = unmergeSCS( obj, scs )
    end
    
end
        