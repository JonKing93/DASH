classdef stateVector
    %
    % *ALL USER METHODS*
    %
    %
    % Create / General Settings:
    %   stateVector
    %   label
    %   verbose
    %
    % Variables:
    %   add
    %   remove
    %   variables
    %   rename
    %   relocate
    %
    % Coupling
    %   couple
    %   uncouple
    %   autocouple
    %
    % Design
    %   design
    %   sequence
    %   metadata
    %   mean
    %   weightedMean
    %   overlap
    %
    % Workflow:
    %   append
    %   extract
    %
    % Build
    %   build
    %   addMembers
    %
    % Summary
    %   info
    %   dimensions
    %   getMetadata
    %
    % 

    properties
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
        autocouple_ = true(0,1);         % Whether variables should be automatically coupled to new variables

        %% Ensemble members / coupled sets

        unused;
        subMembers;
        ensDims;
        whichSet;

    end

    methods

        % General settings
        varargout = label(obj, label);
        name = name(obj);
        assertEditable(obj);

        % Variables
        obj = add(obj, variableNames, grids, autocouple);
        obj = remove(obj, variables);
        varargout = overlap(obj, variables, allowOverlap);
        v = variableIndices(obj, variables, allowRepeats, header);

        % Gridfiles
        obj = relocate(obj, variables, grids);

        % Variable names
        variables = variables(obj, v);
        obj = rename(obj, variables, newNames);
        assertValidNames(obj, newNames, header);

        % Variable dimensions
        dimensions = dimensions(obj, v, cellOutput);
        [indices, dimensions] = dimensionIndices(obj, v, dimensions, header);

        % Coupling
        obj = couple(obj, variables);
        obj = uncouple(obj, variables);
        obj = autocouple(obj, variables, setting);
        obj = updateCoupledVariables(obj, t, vars, header);

        % Design parameters
        obj = design(obj, variables, dimensions, types, indices);
        obj = sequence(obj, variables, dimensions, indices, metadata);
        obj = metadata(obj, variables, dimensions, metadataType, varargin);
        obj = mean(obj, variables, dimensions, indices, NaNoptions);
        obj = weightedMean(obj, variables, dimensions, weights);
        obj = editVariables(obj, vars, d, method, inputs, task);

        % Vector workflow
        obj = extract(obj, variables);
        obj = append(obj, vector2, responseToRepeats)
        copy;

        % Build
        build;
        addMembers;

        % Serialize
        serialize;
        deserialize;

        % Summary information
        info;
%         disp;
%         dispVariables;
    end

    methods (Static)
        [grids, gridIndices, failed, cause] = parseGrids(grids, nVariables, header);
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