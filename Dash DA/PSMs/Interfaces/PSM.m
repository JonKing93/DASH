%% This is an interface that ensures that proxy models can interact with dashDA.
classdef (Abstract) PSM < handle
    % PSM inherits from handle so that the same PSM can be used multiple
    % times but for different observations.
    
    % A variable that is available to all PSMs. Actually using this
    % variable is optional.
    properties
        % This is the index of each observation that uses the PSM within
        % the array of all observations.
        obNum;
    end
    
    % A method that all proxy system models must implement
    methods (Abstract = true)
        
        % This is the basic function used in the dashDA code. The PSM is
        % given state variables, and any other information known by dashDA,
        % and returns model estimates, Ye.
        Ye = runPSM( obj, M, obNum, site, time );
    end
    
    % This is a utility for all PSMs
    methods
        
        % Gets the index of the values in a forward model that are specific
        % to a particular observation.
        function[obDex] = getObIndex( obj, currObNum )
            obDex = find( obj.obNum == currObNum );
        end
        
    end
    
end