classdef serializedStateVectorVariables
    %% dash.serializedStateVectorVariables  Serialize vector of stateVectorVariable objects to support fast save/load operations.
    % ----------
    %   The dash.serializedStateVectorVariables class implements an object
    %   that can serialize a vector of dash.stateVectorVariable objects.
    %
    %   stateVectorVariable objects are highly nested. This helps to
    %   organize design parameters, and also make associated code more
    %   readable. However, a consequence of this nested layout is that
    %   stateVectorVariable objects are slow to save and load from files.
    %   This issue is most noticeable for large vectors of
    %   stateVectorVariable objects. 
    % 
    %   The serializedStateVectorVariables class is designed to address
    %   this issue. The class converts the information stored in a vector
    %   of stateVectorVariable objects into a format that supports fast
    %   save/load operations. Although the serialized object can no longer be used
    %   for stateVectorVariable operations, the original vector can be
    %   rebuilt using the "deserialize" method. Additionally, the
    %   properties of the serialized object can only be set privately. This
    %   ensures that serialized information is read-only, thereby
    %   removing the need to error check the validity of deserialized
    %   vectors.
    % ----------
    % dash.serializedStateVectorVariables methods:
    %
    % Serialization:
    %   serializedStateVectorVariables  - Creates a serialized object from a vector of stateVectorVariable objects
    %   serialize                       - Serializes a vector of stateVectorVariable objects
    %   deserialize                     - Rebuilds a vector of stateVectorVariable objects from a serialized object
    %
    % Unit tests:
    %   tests                           - Implement unit tests for the serializedStateVectorVariables class
    %
    % <a href="matlab:dash.doc('dash.serializedStateVectorVariables')">Documentation Page</a>

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

    methods (Static)
        tests;
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

        % Empty constructor option
        if ~exist('svv','var') || isempty(svv)
            return
        end
        
        % Implement serialization in separate file to support separated
        % utility functions and error messages
        obj = obj.serialize(svv);
        
        end
    end

end