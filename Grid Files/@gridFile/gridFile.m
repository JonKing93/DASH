classdef gridFile
    % A container class that describes a gridded dataset.
    
    properties
        source; % A vector of data sources
        dimOrder; % The internal dimensional order used by the .grid file
        dimLimit; % The index limits of each data source in each dimension (nDim x 2 x nSource)
        metadata; % The metadata along each dimension and data attributes
        gridSize; % The total size of the gridded metadata.
    end
    
    % Static user methods
    methods (Static)
        
        % Exract metadata from existing .grid file
        [meta, dimID, gridSize] = meta( file )
        
        % Create new grid file
        new( filename, type, source, varName, dimOrder, atts, varargin );
        
    end
   
   % Error checking
   methods (Static)
       
       % Check that dimensions are recognized
       [dims] = checkDimList( dims, errName );
       
       % Check that dimensions are recognized and non-duplicate
       [sourceDims] = checkSourceDims( sourceDims )
       
       % Check that metadata is allowed
       [value] = checkMetadata( value, nRows, dim );
       
       % Indicate whether type is allowed for metadata
       [tf] = ismetadatatype( value );
       
   end
   
   % Utilities
   methods (Static)
       
       % Check file existence / extension / correct fields
       fileCheck( file, flag );
       
       % Create the metadata structure
       meta = buildMetadata( dimOrder, gridSize, atts, varargin );
       
       % Pad size to at least d dimensions
       [siz] = fullSize( siz, d )
       
       % Reorder size to internal dimension order
       [gridSize] = permuteSize( gridSize, dimOrder, gridDims )
       
   end
        
end  
        
        