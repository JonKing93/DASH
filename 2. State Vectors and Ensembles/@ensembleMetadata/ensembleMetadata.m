classdef ensembleMetadata
    % ensembleMetadata
    % Manages metadata for a state vector ensemble
    %   
    % ensembleMetadata Methods:
    %   ensembleMetadata - Creates a new ensemble metadata object
    %   lookup - Returns metadata at specified indices
    %   varIndices - Returns the state vector indices associated with a variable
    %   useVars - Returns ensemble metadata for a state vector comprised of specified variables
    %   closestLatLonIndices - Returns state vector indices closest to a
    %                          set of lat-lon coordinates.
    %
    % ensembleMetadata Utility Methods:
    %   dimCheck - Checks that a set of dimensions are in the metadata
    %   varCheck - Checks that a set of variables are in the metadata
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    % The user is not permitted to access any of the properties. These
    % values must be set by the constructor and looked up elsewhere.
    properties (SetAccess = private)
        varName     % Variable name
        varLimit     % Index limits in state vector
        varSize     % Size of gridded data for each variable
        stateMeta     % Metadata for each state element
        ensMeta      % Metadata for each ensemble member
        
        design      % The stateDesign associated with the ensemble        
        ensSize     % The number of state elements and members
    end
        
    % Constructor block
    methods
        function obj = ensembleMetadata( inArg )
            % Constructor for an ensemble metadata object
            %
            % obj = ensembleMetadata( design )
            % Creates an ensemble metadata object for a state vector design.
            %
            % obj = ensembleMetadata( ensFile )
            % Returns the ensemble metadata object for the ensemble saved in a
            % .ens file.
            %
            % ----- Inputs -----
            %
            % design: A state vector design object.
            %
            % ensFile: The name of a .ens file. Either a character vector
            %          or a string.
            %
            % ----- Outputs -----
            %
            % obj: The new ensemble metadata object.

            % If the input is a state design, just use it directly.
            if isa(inArg, 'stateDesign')
                obj.design = inArg;
                if numel(inArg) > 1
                    error('design must be a scalar object. The current design is a stateDesign array.');
                end

            % For an ens file input, error check before extracting desing
            else
                checkFile( inArg, 'extension', '.ens', 'exist', true );
                m = matfile( inArg );
                obj.design = m.design;
            end

            % Record the variable names, index limits, dimensional sizes,
            % used metadata
            obj.varName = obj.design.varName;
            [obj.varLimit, obj.varSize] = obj.design.varIndices;
            [obj.stateMeta, obj.ensMeta] = obj.design.varMetadata;
            
            % Get the size of the ensemble
            obj.ensSize = obj.design.ensembleSize;
        end
    end
    
    % Methods for the user
    methods
        
        % Looks up metadata for a variable
        meta = lookup( obj, dims, inArg );
        
        % Return the indices associated with a variable
        H = varIndices( obj, varName ); 
        
        % Reduces to specified variables
        ensMeta = useVars( obj, vars );
        
        % Reduces to specified ensemble members
        ensMeta = useMembers( obj, members );
    end
    
    % Indexing
    methods 
        
        % Checks that dimensions are in the metadata, converts to string
        dims = dimCheck( obj, dims );
        
        % Checks that variables are in the metadata. Returns variable index
        v = varCheck( obj, vars );
    end
    
    % Lat-lon lookup for PSM development
    methods
        
        % Gets lat-lon metadata for one sequence element of a variable
        latlon = getLatLonMetadata( obj, varName );
        
        % Time metadata for one sequence element
        time = getTimeMetadata( obj, varName );
        
        % Finds the closest state vector elements to a lat-lon coordinate
        H = closestLatLonIndices( obj, coords, varNames, varargin );
        
        % !!!! Patch for rename to closestLatLonIndices, this will be removed in a future release.
        H = getClosestLatLonIndex( obj, coords, varNames, varargin )
        
        % Gets the lat lon metadata for the entire ensemble
        latlon = coordinates( obj );
        
        % Gets timepoints for the entire ensemble
        times = timepoints( obj );
        
    end
             
end