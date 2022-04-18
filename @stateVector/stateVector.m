classdef stateVector
    %% stateVector  Design and build state vector ensembles
    % ----------
    %   The state vector class is used to design and build state vector
    %   ensembles with a minimum of data manipulation. The class uses data
    %   catalogued in .grid files to create variables within a state
    %   vector....
    %   
    %   ....... Lots more introduction ........
    % ----------
    % stateVector methods:
    %
    % **KEY METHODS**
    % The following methods are the most essential for users.
    %
    %   stateVector         - Create a new, empty state vector
    %   add                 - Add variables to a state vector
    %   design              - Design the dimensions of variables
    %   mean                - Take means over dimensions of variables
    %   weightedMean        - Take weighted means over the dimensions of variables
    %   build               - Build a state vector ensemble from a design template
    %
    %
    % *ALL USER METHODS*
    % The complete list of methods for users.
    %
    % Create:
    %   stateVector         - Create a new, empty state vector
    %   label               - Return or specify a label for a state vector
    %
    % Variables:
    %   add                 - Add new variables to a state vector
    %   remove              - Remove variables from a state vector
    %   extract             - Extract variables from a state vector
    %   append              - Append a second state vector to the current state vector
    %   rename              - Change the names of variables
    %   relocate            - Change the location of the gridfile associated with a variable
    %
    % Design:
    %   design              - Design the dimensions of variables in a state vector
    %   mean                - Take means over dimensions of variables
    %   weightedMean        - Take weighted means over dimensions of variables
    %   sequence            - Use a sequence over ensemble dimensions of variables
    %   metadata            - Specify metadata options for dimensions of variables
    %
    % Overlap:
    %   overlap             - Update the overlap settings of variables in a state vector
    %
    % Coupling:
    %   autocouple          - Specify if variables should be automatically coupled to new variables
    %   couple              - Couple indicated variables
    %   uncouple            - Uncouple indicated variables
    %
    % Build:
    %   build               - Build a new state vector ensemble
    %   addMembers          - Add members to an existing state vector ensemble
    %
    % Size Information:
    %   length              - Return the length of the state vector and its variables
    %   members             - Return the number of ensemble members associated with a state vector object
    %
    % Variable Information:
    %   variable            - Display a state vector variable in the console
    %   variables           - List the names of variables in a state vector
    %   dimensions          - Return the dimensions associated with variables
    %   coupledVariables    - List sets of coupled variables
    %
    % General Information:
    %   disp                - Display the state vector in the console
    %   info                - Return information about a state vector or its variables
    %
    % Serialization:
    %   serialize           - Serialize a stateVector object for fast saving/loading
    %   deserialize         - Restore a stateVector object from a serialized state
    %
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. They are not intended for
    % users.
    %
    % General:
    %   name                - Return a name for the state vector for use in error messages
    %   assertEditable      - Throw error if state vector is no longer editable
    %   assertUnserialized  - Throw error is state vector is serialized
    %
    % Variables:
    %   updateLengths       - Update the lengths of indicated variables
    %   assertValidNames    - Throw error if variable names are not valid
    %   editVariables       - Edit the design parameters of state vector variables
    %
    % Indices:
    %   variableIndices     - Parse variables and return indices in state vector
    %   dimensionIndices    - Parse dimensions and return indices in variables
    %
    % Coupling:
    %   coupleDimensions    - Update state and ensemble dimensions to match a template variable
    %   coupledIndices      - Return sets of coupled variable indices
    %   couplingInfo        - Return organized information about coupled variables
    %
    % Build:
    %   buildEnsemble       - Builds members of a state vector ensemble
    %
    % Console Display:
    %   dispVariables       - Display a list of state vector variables in the console
    %   dispCoupled         - Display sets of coupled variables in the console
    %
    % Gridfile Interactions:
    %   parseGrids          - Parse inputs that are either gridfile objects or .grid file paths
    %   buildGrids          - Build unique gridfile objects
    %   validateGrids       - Check that gridfiles match recorded values
    %
    % Unit Tests:
    %   tests               - Implement unit tests for the stateVector class
    %
    %
    % <a href="matlab:dash.doc('stateVector')">Documentation Page</a>

    properties (SetAccess = private)
        %% General settings

        label_ = "";                    % The label for the state vector
        iseditable = true;              % Whether the state vector is editable

        %% Variables

        nVariables = 0;                 % The number of variables in the state vector
        variableNames = strings(0,1);   % The names of the variables in the stateVector
        variables_;                     % The collection of variables and their design parameters
        gridfiles = strings(0,1);       % The gridfile associated with each variable
        allowOverlap = false(0,1);      % Whether ensemble members for a variable are allowed to use overlapping information
        lengths = NaN(0,1);             % The number of state vector elements for each variable

        %% Coupling

        coupled = true(0,0);            % Which variables are coupled to each other
        autocouple_ = true(0,1);        % Whether variables should be automatically coupled to new variables

        %% Ensemble members

        unused;                         % Unused ensemble members for each coupling set
        subMembers;                     % Saved ensemble members subscripted across ensemble dimensions for each coupling set

        %% Serialization

        isserialized = false;           % Whether the state vector is serialized
        nMembers_serialized = [];       % The number of saved ensemble members for a serialized state vector
        nUnused_serialized = [];        % The number of unused ensemble members in each coupling set for a serialized state vector
        nEnsDims_serialized = [];       % The number of ensemble dimensions in each coupling set for a serialized state vector

    end

    methods

        % General
        varargout = label(obj, label);
        name = name(obj, capitalize);
        assertEditable(obj, header);

        % Sizes
        length = length(obj, variables);
        nMembers = members(obj);
        obj = updateLengths(obj, vars);

        % Variables
        obj = add(obj, variableNames, grids, autocouple);
        obj = remove(obj, variables);
        obj = extract(obj, variables);
        obj = append(obj, vector2, responseToRepeats);
        v = variableIndices(obj, variables, allowRepeats, header);

        % Variable names
        variables = variables(obj, v);
        obj = rename(obj, variables, newNames);
        assertValidNames(obj, newNames, header);

        % Dimensions
        dimensions = dimensions(obj, v, types, cellOutput);
        [indices, dimensions] = dimensionIndices(obj, v, dimensions, header);

        % Design
        obj = design(obj, variables, dimensions, types, indices);
        obj = sequence(obj, variables, dimensions, indices, metadata);
        obj = metadata(obj, variables, dimensions, metadataType, varargin);
        obj = mean(obj, variables, dimensions, indices, NaNoptions);
        obj = weightedMean(obj, variables, dimensions, weights);
        obj = editVariables(obj, vars, d, method, inputs, task);

        % Overlap
        varargout = overlap(obj, variables, allowOverlap);

        % Coupling
        obj = couple(obj, variables);
        obj = uncouple(obj, variables);
        obj = autocouple(obj, setting, variables);
        [obj, failed, cause] = coupleDimensions(obj, t, vars, header);

        % Coupling information
        [indexSets, nSets] = coupledIndices(obj);
        [names, indices] = coupledVariables(obj, variables);
        info = couplingInfo(obj);

        % Build / write
        [X, meta, obj] = build(obj, nMembers, varargin);
        [X, meta, obj] = addMembers(obj, nMembers, varargin);
        [X, meta, obj] = buildEnsemble(obj, ens, nMembers, strict, grids, coupling, ...
                                       precision, showprogress, header);

        % Serialization
        assertUnserialized(obj);
        s = serialize(obj);
        obj = deserialize(obj);

        % Information
        info = info(obj, variables);
        variable(obj, variables, dimensions, detailed, suppressVariable);
        disp(obj, showVariables);
        dispVariables(obj, objName);
        dispCoupled(obj, sets);

        % Gridfile interactions
        obj = relocate(obj, variables, grids);
        [failed, cause] = validateGrids(obj, grids, vars, header);
    end
    methods (Static)
        [grids, failed, cause] = parseGrids(grids, nVariables, header);
        [grids, failed, cause] = buildGrids(files);

        % Unit tests
        tests;
    end

    % Constructor
    methods
        function[obj] = stateVector(label)
            %% stateVector.stateVector  Return a new, empty stateVector object
            % ----------
            %   obj = stateVector
            %   Returns a new, empty state vector object. The new stateVector has no
            %   variables associated with it.
            %
            %   obj = stateVector(label)
            %   Also applies a label to the state vector object. If unset, the label is
            %   set to an empty string.
            % ----------
            %   Inputs:
            %       label (string scalar | []): A label for the state vector.
            %
            %   Outputs:
            %       obj (scalar stateVector object): A new, empty stateVector object.
            %
            % <a href="matlab:dash.doc('stateVector.stateVector')">Documentation Page</a>
    
            % Add Label
            if exist('label','var')
                try
                    obj = obj.label(label);
                catch ME
                    throw(ME);
                end
            end

            % Initialize empty stateVectorVariable array
            variables = dash.stateVectorVariable;
            variables(1,:) = [];
            obj.variables_ = variables;

        end
    end

end