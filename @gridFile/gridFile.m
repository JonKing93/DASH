classdef (Abstract) gridFile
    % gridFile
    % A class to hold file IO functions
    %
    % gridFile Methods:
    %   new - Creates a new .grid file
    %   append - Appends data to a .grid file
    %   meta - Returns metadata for a .grid file
    %   rewriteMeta - Rewrites metadata in a .grid file
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    % User methods
    methods (Static)
    
        % Creates a new .grid file
        new( file, gridData, gridDims, appendDims, specs, varargin );
        
        % Appends data to an existing .grid file
        append( file, newData, gridDims, dim, newMeta );
        
        % Extracts metadata from a .grid file
        [meta, dimID, gridSize] = meta( file );
        
        % Rewrites metadata in a .grid file
        rewriteMeta( file, dim, newMeta );
        
    end
    
    % Internal utitlies
    methods (Static)
        
        % Create the metadata structure
        [meta] = buildMetadata( gridDims, gridSize, specs, varargin);
        
        % Get the size of a grid through the Nth dimension
        [siz] = fullSize( X, d );
        
        % Test if data may be written to netcdf
        [tf] = isnctype( data );
        
        % Permutes data grid to match internal dimension order
        [gridData] = permuteGrid( gridData, gridDims, dimID );
        
    end
    
    % Error checking
    methods (Static)
        
        % Append dimensions
        [append] = checkAppendDims( appendDims );
        
        % Appended metadata
        checkAppendMetadata( newMeta, oldMeta, dimLen, dim );
        
        % Dimension name
        checkDim(dim, useSpec);
        
        % Set of dimensions
        [dims] = checkDimList( dims, errName );
        
        % Listed grid dimensions
        [gridDims] = checkGridDims(gridDims);
        
        % Metadata
        [value] = checkMetadata( value, nRows, dim );
        
        % Specs field (attributes)
        checkValidSpecs( specs );
        
        % File name
        fileCheck( file, flag )
        
    end
        
end
        