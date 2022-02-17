classdef serializedStateVectorVariables
    %% dash.serializedStateVectorVariables  Serialize a vector of stateVectorVariable objects to support fast save/load operations.

    % Prohibit serialized values from being altered
    properties (SetAccess = private)
        nDims;
        isState;
        hasSequence;
        omitnan;
        gridSize;
        stateSize;
        ensSize;
        meanSize;
        meanType;
        metadataType;
        convertFunction;
        dims;
        indices;
        nIndices;
        meanIndices;
        nMean;
        sequenceIndices;
        nSequence;
        weights;
        nWeights;
        sequenceMetadata;
        vdSequenceMetadata;
        metadata_;
        vdMetadata;
        convertArgs;
        vdConvertArgs;
    end

    methods
        obj = serialize(obj, svv);
        svv = deserialize(obj);
    end

    % Constructor
    methods
        function[obj] = serializedStateVectorVariables(svv)
        %% dash.serializedStateVectorVariable  Serialize a vector of stateVectorVariable objects to support fast saving/loading
        % ----------
        %   obj = dash.serializedStateVectorVariable(svv)
        %   Serializes a vector of stateVectorVariable objects. Converts nested
        %   fields to serial arrays. Organizes serial arrays and deserialization
        %   parameters in a custom serialized objeect. The serialized object
        %   can call the deserialize method to rebuld the original
        %   vector of objects.
        %
        %   In the serialized object, dimension lists, logical indicators,
        %   sizes, and metadata conversion function handles are converted to comma
        %   delimited string vectors. (Commas delimit entries for different
        %   dimensions). Indices, and mean weights are converted to column vectors,
        %   and the numbers of indices in each dimension are stored as comma
        %   delimited string vectors. Metadata and conversion function args are
        %   stored as cell columns vectors with minimal elements, along with the
        %   variable and dimension index associated with each cell element.
        % ----------
        %   Inputs:
        %       svv (vector, stateVectorVariable objects): The vector of
        %           state vector variable objects that should be serialized.
        %
        %   Outputs:
        %       obj (scalar serializedStateVectorVariable object): The serialized state vector variable.
        %
        % <a href="matlab:dash.doc('dash.serializedStateVectorVariable.serializedStateVectorVariable')">Documentation Page</a>
        
        % Implement serialization in separate file to support separated
        % utility functions and error messages
        obj = obj.serialize(svv);
        
        end
    end

end