classdef stateVector

    properties (SetAccess = private)
        %% General settings

        label_ = "";                    % The label for the state vector
        iseditable = true;              % Whether the state vector is editable

        %% Variables

        nVariables = 0;                 % The number of variables in the state vector
        variableNames = strings(0,1);   % The names of the variables in the stateVector
        variables_ = [];                % The collection of variables and their design parameters
        gridfiles = strings(0,1);       % The gridfile associated with each variable
        allowOverlap = false(0,1);      % Whether ensemble members for a variable are allowed to use overlapping information

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
        length = length(obj);
        nMembers = members(obj);
        assertEditable(obj);

        % Variables
        obj = add(obj, variableNames, grids, autocouple);
        obj = remove(obj, variables);
        obj = extract(obj, variables);
        obj = append(obj, vector2, responseToRepeats);
        v = variableIndices(obj, variables, allowRepeats, header);
        varargout = overlap(obj, variables, allowOverlap);

        % Variable names
        variables = variables(obj, v);
        obj = rename(obj, variables, newNames);
        assertValidNames(obj, newNames, header);

        % Dimensions
        dimensions = dimensions(obj, v, cellOutput);
        [indices, dimensions] = dimensionIndices(obj, v, dimensions, header);

        % Design
        obj = design(obj, variables, dimensions, types, indices);
        obj = sequence(obj, variables, dimensions, indices, metadata);
        obj = metadata(obj, variables, dimensions, metadataType, varargin);
        obj = mean(obj, variables, dimensions, indices, NaNoptions);
        obj = weightedMean(obj, variables, dimensions, weights);
        obj = editVariables(obj, vars, d, method, inputs, task);

        % Coupling
        obj = couple(obj, variables);
        obj = uncouple(obj, variables);
        obj = autocouple(obj, variables, setting);
        [obj, failed, cause] = coupleDimensions(obj, t, vars, header);

        % Coupling information
        [indexSets, nSets] = coupledIndices(obj);
        [names, indices] = coupledVariables(obj);
        info = couplingInfo(obj);

        % Build / write
        [X, meta, obj] = build(obj, nMembers, varargin);
        [X, meta, obj] = buildEnsemble(obj, ens, nMembers, strict, grids, coupling, showprogress);
        [X, meta, obj] = addMembers(obj, nMembers, varargin);

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
        [failed, cause] = validateGrids(obj, grids, vars, header);
        obj = relocate(obj, variables, grids);
    end
    methods (Static)
        [grids, failed, cause] = parseGrids(grids, nVariables, header);
        [grids, failed, cause] = buildGrids(files, nVariables);

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
                obj = obj.label(label);
            end
        end
    end

end