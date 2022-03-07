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
        assertEditable(obj);
        length = length(obj, variables);
        nMembers = members(obj);
        obj = updateLengths(obj, vars);

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
        dimensions = dimensions(obj, v, types, cellOutput);
        [indices, dimensions] = dimensionIndices(obj, v, dimensions, header);

        % Design
        obj = design(obj, variables, dimensions, indices, types);
        obj = sequence(obj, variables, dimensions, indices, metadata);
        obj = metadata(obj, variables, dimensions, metadataType, varargin);
        obj = mean(obj, variables, dimensions, indices, NaNoptions);
        obj = weightedMean(obj, variables, dimensions, weights);
        obj = editVariables(obj, vars, d, method, inputs, task);

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
                try
                    obj = obj.label(label);
                catch ME
                    throw(ME);
                end
            end
        end
    end

end