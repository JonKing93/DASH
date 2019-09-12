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
    
    % Constructor
    methods
        function obj = ensembleMetadata( design )
        end 
    end
    
    
    
    % These are public methods that anyone can use
    methods (Access = public)
        
        
        
        
        
    end
    
    
    
    % These are internal methods.
    methods (Access = private)
        
        % Check if variables are in the ensemble and return their indices
        % in the set of variables.
        v = varCheck(obj, varNames);
        
        % Return all the indices associated with a particular variable
        H = varIndices( obj, varName );
        
        
    end
    
    
    
    
    
    
    
    % But they can name for quick reference
    
    % These are public methods that anyone can use
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
        
        function meta = lookupMetadata( obj, dims, inArg )
            % Returns ensemble metadata at specific indices.
            %
            % meta = obj.lookupMetadata( dims, H )
            % Returns the metadata along dimension 'dim' at state indices 'H'.
            %
            % meta = obj.lookupMetadata( dims, varName )
            % Returns the metadata along dimension 'dim' at all indices for
            % the specified variable.
            %
            % ***Note: H and varName may not reference more than 1
            % variable.
            %
            % ----- Inputs -----
            %
            % dims: A set of dimension names. Either a single character
            %       vector, cellstring, or string array,.
            %
            % H: A vector of indices in the state vector. May not contain
            % indices for more than 1 variable.
            %
            % varName: The name of a variable.
            % 
            % ----- Outputs -----
            %
            % meta: 
            %   If a single dimension is specified, a matrix of metadata. 
            %   Each row corresponds to a specific index.
            %
            %   If multiple dimensions are specified, returns a structure.
            %   The fields of the structure are the metadata matrices for
            %   each queried dimension.
            
            % Check that the dimension is in the ensemble metadata
            dims = obj.dimCheck( dims );
            
            % Convert the input argument into state indices
            H = obj.getLookupIndex( inArg );
            
            % Get the variable referenced by each state index. Note that H
            % is a row, while varLim is a column, so the output is a
            % logical matrix. Use two outputs for find to subscript the row
            % (variable) for each inex.
            [v, ~] =  find(  H' >= obj.varLim(:,1)  &  H' <= obj.varLim(:,2)  );
            
            % Check that there is only a single variable
            v = unique(v);
            if numel(v)~=1
                error('H cannot reference more than a single variable.');
            end
            
            % Adjust H indices so they are 1 indexed to the start of each
            % variable
            H = H - obj.varLim(v,1) + 1;
            
            % Get the N-dimensional subscript indices
            subDex = subdim( obj.varSize(v,:), H );
            
            % Initialize the metadata structure
            meta = struct();
            
            % Get the metadata at each index for each dimension
            for d = 1:numel(dims)
                meta.(dims(d)) = obj.varData(v).(dim)( subDex(:,d), : );
            end
            
            % If there's only a single dimension, just return the array
            if numel(dims) == 1
               meta = meta.(dims);
            end
        end
        

    
    % These are some utility functions that the user doesn't need to worry
    % about
    methods (Access = private)
        function dims = dimCheck( obj, dims )
            % Checks if a set of dimensions are in the ensemble metadata.
            % Returns them as a string array.
            
            % Check that dims is either a character row, cellstring, or
            % string
            if ~isstrset(dims)
                error('dims must be a character row vector, cellstring, or string array.');
            end
            
            % Convert to string for simplicity
            dims = string(dims);
            
            % Check that the dims are actually in the ensemble metadata
            goodDims = fields( obj.varData );
            if any( ~ismember( dims, goodDims ) )
                error('"%s" is not a dimension in the ensemble metadata.', dims( find(~ismember(dims,goodDims),1) ) );
            end
        end
            
          
            
        function H = getLookupIndex( obj, inArg )
            % Parses the input for lookupMetadata
            
            % If a string flag, this is a variable name
            if isstrflag( inArg )
                
                % Check that the variable is in the ensemble metadata
                obj.varCheck(inArg);
                
                % Get the entire set of variable indices
                H = obj.varIndex( inArg );
            
            % Otherwise, this is a set of indices
            else
                H = inArg;
                
                % Error check
                if ~isvector(inArg) || ~isnumeric(inArg) || any(inArg < 1) || any(mod(inArg,1)~=0)
                    error('H indices must be a numeric vector of positive integers.');
                
                % Ensure the indices are in the ensemble
                elseif any( H > obj.varLim(end,2) )
                    error('H contains indices longer than the state vector.');
                end
                
                % Ensure H is a column
                H = H(:);
            end
        end
    end
end