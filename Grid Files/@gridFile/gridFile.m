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
        
        % Create a metadata structure for a grid or gridded data
        [meta] = defineMetadata( varargin )
        
        % Create new grid file
        new( filename, type, source, varName, dimOrder, atts, varargin );
        
        % Adds data to a .grid file
        addData( file, type, source, varName, dimOrder, meta );
        
        % Exract metadata from existing .grid file
        [meta, dimID, gridSize] = meta( file );
        
        % Increase the size of a dimension in a .grid file.
        expand( file, dim, newMeta );
        
        % Change metadata along a dimension
        rewriteMetadata( file, dim, newMeta );
        
    end
   
   % Error checking
   methods (Static)
       
       % Check file existence / extension / correct fields
       fileCheck( file, flag );
       
       % Check that dimensions are recognized
       [dims] = checkDimList( dims, errName );
       
       % Check that dimensions are recognized and non-duplicate
       [sourceDims] = checkSourceDims( sourceDims );
       
       % Check that metadata is allowed
       checkMetadata( meta );
       
       % Indicate whether type is allowed for metadata
       [tf] = ismetadatatype( value );
       
       % Whether data overlaps existing data
       checkOverlap( dimLimit, gridLimit );
       
       % Permutes source grid data to match grid order
       [X] = permuteSource( X, sourceOrder, gridOrder );
       
       % Returns requested data from sources
       [X] = read( file, start, count, stride );
       
       % Reorders grid scs for source grid order
       [start, count, stride] = reorderSCS( start, count, stride, gridOrder, sourceOrder )
       
   end
        
end  
        
        