classdef ensemble
    %% ensemble  Manipulate and load saved state vector ensembles
    % ----------
    %   Introduction
    % ----------
    % ensemble Methods:
    %
    % *All User Methods*
    %
    % Create:
    %   ensemble        - Build an ensemble object for a .ens file
    %   label           - Set or return the label for an ensemble object
    %
    % Subset data:
    %   useVariables    - Indicate the variables that should be loaded
    %   useMembers      - Indicate which ensemble members should be loaded
    %
    % Metadata:
    %   metadata        - Return metadata for the state vector ensemble
    %
    % Load:
    %   load            - Load requested variables and members of the state vector ensemble
    %   loadRows        - Load specific rows of the state vector ensemble
    %   loadGrids       - Load gridded data instead of state vectors
    %
    % Information:
    %   variables       - List variables in the state vector ensemble
    %   length          - Return the length of the state vector and its variables
    %   members         - Return the number of ensemble members
    %   disp            - Display the ensemble in the console
    %
    % Evolving Prior:
    %   evolving        - Design an evolving ensemble
    %
    % Add:
    %   addMembers      - Add additional members to an ensemble
   


    properties (SetAccess = private)
        
        %% General

        file = "";                  % The absolute path to the .ens file
        label_ = "";                % A label for the ensemble object

        %% Variables

        variables_ = strings(0,1);  % The variables in the .ens file
        varLimit = NaN(0,2);        % The limits of each variable in the full state vector
        lengths = NaN(0,1);         % The length of each variable

        %% Sizes

        

        %% Subsets

        v = [];                     % The indices of variables to load
        m = [];                     % The indices of members to load

        %% Evolving

        isevolving = false;         % Whether the ensemble is evolving
        evolvingMembers;            % The members in each iteration of the evolving ensemble

    end



    methods




