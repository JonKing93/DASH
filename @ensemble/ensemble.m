classdef ensemble

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
        