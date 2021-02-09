classdef baysplinePSM < PSM
    % Implements the BAYSPLINE UK37 PSM
    % Requires the Curve Fitting Toolbox
    %
    % baysplinePSM Methods:
    %   baysplinePSM - Creates a new baysplinePSM object
    %   run - Runs BAYSPLINE directly
    
    methods
        % Constructor
        function[obj] = baysplinePSM(row, name)
            %% Creates a new BAYSPLINE PSM
            %
            % obj = baysplinePSM(row)
            % Creates a BAYSPLINE PSM for a set of SST values.
            %
            % obj = baysplinePSM(row, name)
            % Optionally names the PSM.
            %
            % ----- Inputs -----
            %
            % row: The state vector row with the SST values required to run
            %    the PSM. A positive integer.
            %
            % name: An optional name for the PSM. A string
            %
            % ----- Outputs -----
            %
            % obj: The new baysplinePSM object
        
            % Set name, estimatesR
            if ~exist('name','var')
                name = "";
            end            
            obj@PSM(name, true);
            
            % Check and set rows
            assert(isscalar(row), 'row must be a scalar');
            obj = obj.useRows(row);
        
        end
        
        % Run the PSM
        function[UK, R] = runPSM(~, SSTs)
            %% Runs a baysplinePSM object
            %
            % [UK, R] = obj.run(SSTs)
            %
            % ----- Inputs -----
            %
            % SSTs: The SSTs for the BAYSPLINE model. A numeric row vector.
            %
            % ----- Outputs -----
            %
            % UK: A row vector of UK37 estimates.
            %
            % R: Uncertainty estimates from the posterior.
     
            % Currently, there are no additional parameters, so can just
            % call the static method directly.
            [UK, R] = baysplinePSM.run(SSTs);
        end
    end
    
    % Run directly
    methods (Static)
        function[Y, R] = run(ssts)
            %% Runs the BAYSPLINE PSM directly
            %
            % [Y, R] = baysplinePSM.run(ssts)
            % Applies BAYSPLINE to a set of SSTs to estimate UK37 values
            % and associated uncertainty.
            %
            % ----- Inputs -----
            %
            % ssts: A vector of sea surface temperatures (in Celsius).
            %    Please see the BAYSPLINE documentation for more details.
            %
            % ----- Outputs -----
            %
            % Y: A vector of UK37 estimates.
            %
            % R: UK37 uncertainties estimated from the posterior. A vector.
            
            % Error check ssts
            assert(isnumeric(ssts), 'ssts must be numeric');
            assert(isvector(ssts), 'ssts must be a vector');
            
            % Run the PSM. Get the posterior mean and estimate R
            uk = UK_forward(ssts);
            Y = mean(uk, 2);
            R = var(uk, [], 2);
            
            % Shape to the sst vector
            if isrow(ssts)
                Y = Y';
                R = R';
            end
        end  
    end
          
end
  