%% This is a class that sets up a proxy model
classdef (Abstract) PSM
    
    % All proxy system models must follow this basic format
    methods (Abstract = true)
        Ye = runPSM( obj, M, coord, time );
    end
    
end