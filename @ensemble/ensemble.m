classdef ensemble
    %% ensemble  Manipulate and load saved state vector ensembles
    % ----------
    %   Introduction
    % ----------
    % ensemble Methods:
    %
    % *ALL USER METHODS*
    % The complete list of methods for users.
    %
    % Create:
    %   ensemble        - Create an ensemble object for a saved state vector ensemble
    %   label           - Set or return a label for an ensemble object
    %
    % Subset:
    %   useVariables    - Use a subset of saved variables
    %   useMembers      - Use a subset of saved ensemble members
    %
    % Evolving ensembles:
    %   evolving        - Implement an evolving ensemble
    %   labelEvolving   - Label the different ensembles in an evolving ensemble
    %
    % Metadata:
    %   metadata        - Return the ensembleMetadata object for an ensemble
    %
    % Sizes:
    %   nRows           - Return the number of state vector rows for one or more ensemble objects
    %   nVariables      - Return the number of state vector variables for one or more ensemble objects
    %   nMembers        - Return the number of ensemble members for one or more ensemble objects
    %   nEnsembles      - Return the number of ensembles implemented by static or evolving ensemble objects
    %
    % Load:
    %   load            - Loads a state vector ensemble into memory
    %   loadGrids       - Loads the variables of a state vector ensemble as gridded fields
    %   loadRows        - Loads specific rows of a state vector ensemble
    %
    % Information:
    %   length          - Return the state vector length of an ensemble and its variables
    %   variables       - List the variables used in an ensemble
    %   members         - List the ensemble members used in an ensemble
    %   info            - Return information about an ensemble as a struct
    %
    % Add members:
    %   addMembers      - Add more members to a saved state vector ensemble
    %
    % Console display:
    %   disp            - Displays an ensemble object in the console

    properties (SetAccess = private)
        %% General settings

        file = strings(0,1);        % The .ens file associated with the object
        label = "";                 % An identifying label for the ensemble

        %% Variables

        variables_ = strings(0,1);  % The names of the variables in the .ens file
        use = false(0,1);           % Whether each variable is being used by the ensemble object

        %% Members

        isevolving = false;         % Whether the ensemble is an evolving ensemble
        members;
    end

    methods
        
        %% General

        varargout = label(obj, label);

        %% Sizes

        nRows = nRows(obj, scope);
        nVariables = nVariables(obj, scope);
        nMembers = nMembers(obj, scope);
        nEnsembles = nEnsembles(obj, scope);

