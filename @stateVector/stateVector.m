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
    %   copy
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
        verbose_ = false;               % Whether the state vector should be verbose
        iseditable = true;              % Whether the state vector is editable

        %% Variables

        nVariables = 0;                 % The number of variables in the state vector
        variableNames = strings(0,1);   % The names of the variables in the stateVector
        variables_ = [];                % The collection of variables and their design parameters
        allowOverlap = false(0,1);      % Whether ensemble members for a variable are allowed to use overlapping information

        %% Coupling

        coupled = true(0,0);            % Which variables are coupled to each other
        autocouple_ = true(0,1);         % Whether variables should be automatically coupled to new variables

    end

    methods

        % General settings
        varargout = label(obj, label);
        name = name(obj);
        varargout = verbose(obj, verbose);
        assertEditable(obj);

        % Variables
        obj = add(obj, variableNames, grids, autocouple, verbose);
        obj = remove(obj, variables);
        varargout = overlap(obj, variables, allowOverlap);
        v = variableIndices(obj, variables, allowRepeats, header);
        relocate;

        % Variable names
        variables = variables(obj, v);
        obj = rename(obj, variables, newNames);
        assertValidNames(obj, newNames, header);

        % Variable dimensions
        dimensions = dimensions(obj, v, cellOutput);
        [indices, dimensions] = dimensionIndices(obj, v, dimensions, header);

        % Coupling
        couple(obj, variables, verbose);
        uncouple(obj, variables, verbose);
        autocouple(obj, variables, setting, verbose);

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

        % Summary information
        info;
%         disp;
%         dispVariables;
    end

    % Constructor
    methods
        function[obj] = stateVector(label, verbose)
            %% stateVector.stateVector  Return a new, empty stateVector object
            % ----------
            %   obj = stateVector
            %   Returns a new, empty state vector object. The new stateVector has no
            %   variables associated with it.
            %
            %   obj = stateVector(label)
            %   Also applies a label to the state vector object. If unset, the label is
            %   set to an empty string.
            %
            %   obj = stateVector(label, verbose)
            %   Sets the verbosity of the new state vector. This is most useful when 
            %   troubleshooting coupled variables. By default, state vectors
            %   are not verbose. If a state vector is made verbose, it will print
            %   notifications to the console when a command alters variables that are
            %   not included in its inputs. This usually occurs because the altered
            %   variables are coupled to variables included in the command's inputs.
            % ----------
            %   Inputs:
            %       label (string scalar | []): A label for the state vector.
            %       verbose (scalar logical): Use true if the state vector
            %           should notify the console when secondary coupled
            %           variables are altered by a command. Use false
            %           (default) if not.
            %
            %   Outputs:
            %       obj (scalar stateVector object): A new, empty stateVector object.
            %
            % <a href="matlab:dash.doc('stateVector.stateVector')">Documentation Page</a>
    
            % Add Label
            if exist('label','var')
                obj = obj.label(label);
            end
    
            % Set verbosity
            if exist('verbose','var')
                obj = obj.verbose(verbose);
            end
        end
    end

end