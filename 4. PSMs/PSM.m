%% This is an interface that ensures that proxy models can interact with dashDA.
%
% Methods:
%   runPSM( obj, M, d, H, t )
%   getStateIndices( obj, ensMeta )

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef (Abstract) PSM
    
    % A method that all proxy system models must implement
    methods (Abstract = true)
        
        % This is the basic function used in the dashDA code to run a PSM.
        % 
        % ----- Inputs -----
        %
        % obj: The PSM
        %
        % M: State elements required to run the PSM
        %
        % d: The index of the observation being processed.
        %
        % H: The sampling indices used to select state elements
        %
        % t: The time step being processed in the DA
        Ye = runPSM( obj, M, d, H, t);

        % This generates the sampling indices for a site
        H = getStateIndices( obj, ensMeta );
    end
    
end