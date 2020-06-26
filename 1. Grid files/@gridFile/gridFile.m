classdef gridFile < handle
    % Provides methods for creating and editing .grid files. These are
    % containers that organize data source, such as NetCDF and .mat files.
    %
    % gridFile Methods:
    %   defineMetadata - Creates a metadata structure for a .grid file, or gridded data source.
    %   new - Creates a new .grid file.
    %   addData - Adds data to a .grid file.
    %   meta - Returns the metadata for a .grid file.
    %   expand - Increases the size of a dimension in a .grid file
    %   rewriteMetadata - Rewrites metadata for a dimension in a .grid file.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    % Properties for the full gridfile
    properties
        filepath; % The current file
        dimOrder; % The internal dimensional order used by the .grid file
        gridSize; % The total size of the gridded metadata.
        metadata; % The metadata along each dimension and data attributes
        nSource;  % Number of data sources
        dimLimit; % The index limits of each data source in each dimension (nDim x 2 x nSource)
    end
    
    properties (Constant)
        attributesName = 'attributes';
    end
    
%     % File fields for data sources that are not actual properties of the grid object
%         sourcePath;   % File path of a data source
%         sourceFile;   % Just the file name
%         sourceVar;    % Name of the variable in the data source
%         sourceDims;   % Name of dimensions in the data source. Comma delimited char.
%         sourceOrder;  % Dimension order in the data source. Comma delimited char
%         sourceSize;   % Size of the (merged) dimensions in the data source.
%         unmergedSize; % Size of unmerged data within the data source
%         merge;        % Maps unmerged dimensions to merged dimensions
%         unmerge;      % Maps merged dimensions to unmerged dimensions
%         
%         counter;      % Tracks how much of preallocated source fields are used.
%                       %     (nChars) path, file, var, dims, order
%                       %     (nDims)  merge size, unmerge size, merge, unmerge
    
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
    
    % Object user methods
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
       
       % Create a dataGrid object from stored data
       [source] = buildSource( obj, s );
        
    end
    
    % Static Utils (error checking and read)
    methods (Static)
       
       % Returns requested data from sources
       [X, passVals] = read( obj, scs, passVals );
       
       % Increases the preallocated size of fields in the .grid file when
       % they are too short
       [m, newVars, newCount] = ensureFieldSize( m, newVars );
       
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
        
        