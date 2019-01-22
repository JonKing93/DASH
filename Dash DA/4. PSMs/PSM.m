%% This is an interface that ensures that proxy models can interact with dashDA.
classdef (Abstract) PSM
    
    % A method that all proxy system models must implement
    methods (Abstract = true)
        
        % This is the basic function used in the dashDA code to run a PSM.
        Ye = runPSM( obj, M, d, H, t);

        % This generates the sampling indices for a site
        H = sampleIndices( obj, ensMeta );
    end
    
end