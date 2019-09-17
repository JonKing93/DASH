classdef ensembleMetadata
    % ensembleMetadata
    % Manages metadata for a state vector ensemble
    % 
    % ensembleMetadata Properties:
    %   varName - The name of each variable
    %   varLim - The index limits of each variable in the state vector
    %   varSize - The original size of the gridded variable
    %   varData - The metadata values associated with the variable
    %
    %   fileName - The name of the associated .ens file
    %   designName - The name of the associated state design
    %   
    % ensembleMetadata Methods:
    %   ensembleMetadata - Creates a new ensemble metadata object
    %   lookupMetadata - Returns metadata at specified indices
    %   varIndex - Returns the state vector indices associated with a
    %              variable
    %
    % ensembleMetadata Utility Methods:
    %   dimCheck - Checks that a set of dimensions are in the metadata
    %   varCheck - Checks that a set of variables are in the metadata
    %   getLookupIndex - Parses inputs for 
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    % The user is not permitted to access any of the properties. These
    % values must be set and looked up by the constructor.
    properties (SetAccess = private)
        varName     % Variable name
        varLimit     % Index limits in state vector
        varSize     % Size of gridded data for each variable
        stateMeta     % Metadata for each state element
        ensMeta      % Metadata for each ensemble member
        
        fileName    % Ensemble metadata file
        design      % The stateDesign associated with the ensemble
        
        ensSize     % The number of state elements and members
        hasnan      % Whether ensemble members contain NaN values
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
                m = ensFileCheck( inArg );
                obj.design = m.design;
                obj.fileName = string(inArg);
            end

            % Record the variable names, index limits, dimensional sizes,
            % used metadata
            obj.varName = design.varName;
            [obj.varLimit, obj.varSize] = design.varIndices;
            [obj.stateMeta, obj.ensMeta] = design.varMetadata;
            
            % Get the size of the ensemble
            ensDim = find( ~design.var(1).isState, 1 );
            nEns = numel( design.var(1).drawDex{ensDim} );
            nState = obj.varLimit(end);
            obj.ensSize = [nState, nEns];
        end
    end
    
    % Methods for the user
    methods
        
        % Looks up metadata for a variable
        meta = lookupMetadata( obj, dims, inArg );
        
        % Return the indices associated with a variable
        H = varIndices( obj, varName ); 
    end
    
    % Internal utilities
    methods (Access = private)
        
        % Checks that dimensions are in the metadata, converts to string
        dims = dimCheck( obj, dims );
        
        % Checks that variables are in the metadata. Returns variable index
        v = varCheck( obj, vars );
    end
end