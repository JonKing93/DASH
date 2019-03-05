%% This is an interface that ensures that proxy models can interact with dashDA.
%
% Methods:
%   runPSM( obj, M, d, t )
%   getStateIndices( obj, ensMeta )

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef (Abstract) PSM < handle
    
    % Some properties used by the DA to run the PSM
    properties
        H; % Sampling indices
        timeDependent = false; % Whether the PSM is time dependent
        bias = [];  % A bias correction structure
    end
    
    % Methods that all proxy system models must implement, but that are
    % unique for all PSMs
    methods (Abstract = true)
        
        % This generates the sampling indices for a site
        getStateIndices( obj, ensMeta );
        
        % Internal error checking
        reviewPSM( obj );
        
        % Converts DA units to PSM units
        M = convertM( obj, M );
        
        % This is the basic function used in the dashDA code to run a PSM.
        % 
        % ----- Inputs -----
        %
        % obj: The PSM
        %
        % M: State elements required to run the PSM
        %
        % t: The time step being processed in the DA
        %
        % d: The index of the observation being processed.
        [Ye, R] = runPSM( obj, M, t, d);
    end
    
    % A switch that selects the appropriate bias correction algorithm.
    methods
        function[X] = biasCorrect( obj, Xd )
            
            % If no bias correction, just use the input value.
            if isempty(obj.bias)
                X = Xd;
                
            % NPDFT corrector
            elseif isa( obj.bias, 'npdftCorrector')
                X = obj.staticNPDFT( Xd );
                
            % Unrecognized bias corrector
            else
                error('Unrecognized bias corrector.');
            end
        end
    end
    
    % NPDFT bias correction. Uses a npdftCorrector bias correction object.
    methods
        % Create the static npdft mapping. 
        function[] = initialNPDFT( obj, Xo, M, tol, varargin )
            
            % Check that sampling indices were generated
            if isempty(obj.H)
                error('Cannot run an initial NPDFT until the sample indices are generated.');
            end
    
            % Select at sampling indices and convert units
            M = M( obj.H, : );
            M = obj.convertM(M);
            
            % Transpose from state vector for npdft
            Xo = Xo';
            M = M';
            
            % Run Npdft. Record static iteration values.
            [~, E, R, normO, normM] = npdft( Xo, M, tol, varargin{:} );
            
            % Save bias correction fields
            obj.bias = npdftCorrector( E, R, normO, normM, Xo, M );
        end
        
        % Do the static NPDFT mapping
        function[X] = staticNPDFT( obj, Xd )
            
            % Convert units
            Xd = obj.convertM( Xd );
            
            % Ensemble members become samples
            Xd = Xd';
            
            % Run a static npdft
            X = npdft_static( obj.bias.Xo, obj.bias.Xm, Xd, obj.bias.R, ...
                              obj.bias.normO, obj.bias.normM );
                          
            % Flip back to state vector format
            X = X';
        end
    end

end