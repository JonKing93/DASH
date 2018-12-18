%% This is an interface that ensures that proxy models can interact with dashDA.
classdef (Abstract) PSM
    
    % A method that all proxy system models must implement
    methods (Abstract = true)
        
        % This is the basic function used in the dashDA code. The PSM is
        % given state variables, and any other information known by dashDA,
        % and returns model estimates, Ye.
        Ye = runPSM( obj, M, obDex, site, time );
    end
    
end