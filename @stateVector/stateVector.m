classdef stateVector

    properties
        %% General settings

        label_ = "";                    % The label for the state vector
        verbose_ = false;               % The verbosity of the state vector

        %% Variables

        nVariables = 0;                 % The number of variables in the state vector
        variableNames = strings(0,1);   % The names of the variables in the stateVector
        variables_ = [];                % The collection of variables and their design parameters
        allowOverlap = false(0,1);      % Whether ensemble members for a variable are allowed to use overlapping information

        %% Coupling

        autoCouple = true(0,1);         % Whether a variable should be automatically coupled to new variables
        coupled = true(0,0);            % Which variables are coupled to each other

    end

    methods

        % General settings
        varargout = label(obj, label);
        varargout = verbose(obj, verbose);
        name = name(obj);

        % Variables
        add;
        remove;
        overlap;
        v = variableIndices(obj, variables, allowRepeats, header);

        % Variable names
        variables = variables(obj, v);
        obj = rename(obj, variables, newNames);
        assertValidNames(obj, newNames, v, header);

        % Coupling
        couple;
        uncouple;

        % Design
        obj = design(obj, variables, dimensions, types, indices);
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
            %   .......WRITE THIS!!!!!
            % ----------
            %   Inputs:
            %       label (string scalar | []): A label for the state vector.
            %       verbose (scalar logical): !!!!!!!!!!!
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