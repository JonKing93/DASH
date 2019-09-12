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
        varLim      % Index limits in state vector
        varSize     % Size of gridded data
        varData     % Metadata for each dimension
        
        fileName    % Ensemble metadata file
        designName  % State design name
    end
        
    % Constructor block (unfinished)
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

            % Get the state design associated with the input argument
            % !!!! The file bits are not finished.
            if isa(inArg, 'stateDesign')
                design = inArg;
                if numel(inArg) > 1
                    error('design must be a scalar object. The current design is a stateDesign array.');
                end
            else
                m = ensFileCheck(inArg, 'load');
                design = m.design;
                obj.fileName = string(inArg);
            end
            obj.designName = design.name;

            % Record the variable names
            obj.varName = design.varName;

            % Get the limits and sizes
            [obj.varLim, obj.varSize] = getVarIndices( design.var );
            % !!! This should be a design object method
            
            % Get the metadata associated with each variable.
            for v = 1:numel( design.var )
                if v == 1  % Initialize the structure for variable 1
                    obj.varData = getVarEnsMeta( design.var(v) );
                end
                obj.varData(v) = getVarEnsMeta( design.var(v) );
                % !!! This should be a design object method.
            end
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