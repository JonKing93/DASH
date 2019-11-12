classdef gridFile < handle
    % Provides methods for creating and editing .grid files. These are
    % containers for various data sources, including NetCDF files, .mat
    % files, and MATLAB workspace arrays.
    %
    % gridFile Methods:
    %   defineMetadata - Creates a metadata structure for a .grid file, or gridded data source.
    %   new - Creates a new .grid file.
    %   addData - Adds data to a .grid file.
    %   meta - Returns the metadata for a .grid file.
    %   expand - Increases the size of a dimension in a .grid file
    %   rewriteMetadata - Rewrites metadata for a dimension in a .grid file.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    properties
        filepath; % The current file
        source;   % A vector of data sources
        dimOrder; % The internal dimensional order used by the .grid file
        dimLimit; % The index limits of each data source in each dimension (nDim x 2 x nSource)
        metadata; % The metadata along each dimension and data attributes
        gridSize; % The total size of the gridded metadata.
    end
    
    % Constructor
    methods
        function obj = gridFile( file )
            obj.filepath = string( which(file) );
            obj.update;
        end
    end    
    
    % Static user methods
    methods (Static)
        
        % Create a metadata structure for a grid or gridded data
        [meta] = defineMetadata( varargin )

        % Exract metadata from existing .grid file
        [meta, dimID, gridSize] = meta( file );
        
        % Create new grid file
        grid = new( filename, type, source, varName, dimOrder, atts, varargin );
        
    end
    
    % User methods
    methods
        
        % Adds data to a .grid file
        addData( obj, type, source, varName, dimOrder, meta );
        
        % Increase the size of a dimension in a .grid file.
        expand( obj, dim, newMeta );
        
        % Change metadata along a dimension
        rewriteMetadata( obj, dim, newMeta );
         
    end
   
    % Utilities
    methods
       
       % Updates the object to reflect the saved file
       update( obj );
        
    end
    
    
   % Static Utils (error checking and read
   methods (Static)
       
       % Returns requested data from sources
       [X, passVals] = read( obj, scs, passVals );
       
       % Check file existence / extension / correct fields
       m = fileCheck( file, flag );
       
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
       
       % Reorders grid scs for source grid order
       [scs] = reorderSCS( scs, gridOrder, sourceOrder )
       
   end
        
end  
        
        