classdef baysplinePSM < PSM
    % Implements the BAYSPLINE PSM, a Bayesian model for UK37 by Jess
    % Tierney.
    %
    % Prerequisites: Requires the Curve Fitting Toolbox
    %
    % Find it on Github at: https://github.com/jesstierney/BAYSPLINE
    %
    % Or read the paper:
    % Tierney, J.E. & Tingley, M.P. (2018) BAYSPLINE: A New Calibration for
    % the Alkenone Paleothermometer. Paleoceanography and 
    % Paleoclimatology 33, 281-301, [http://doi.org/10.1002/2017PA003201].
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
        % Run directly
    methods (Static)
        function[Y, R] = run(ssts)
            %% Runs the BAYSPLINE UK37 forward model.
            %
            % [UK37, R] = baysplinePSM.run(ssts)
            % Applies BAYSPLINE to a set of SSTs to estimate UK37 values
            % and associated uncertainty.
            %
            % ----- Inputs -----
            %
            % ssts: A vector of sea surface temperatures (in Celsius).
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
    
    methods
        % Constructor
        function[obj] = baysplinePSM(row, name)
            %% Creates a new baysplinePSM object
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
            %    the PSM.
            %
            % name: An optional name for the PSM. A string
            %
            % ----- Outputs -----
            %
            % obj: The new baysplinePSM object
        
            % Set name, estimatesR, row
            if ~exist('name','var')
                name = "";
            end            
            obj@PSM(name, true);
            obj = obj.useRows(row, 1);
        
        end
        
        % Run the PSM
        function[UK, R] = runPSM(~, SSTs)
            %% Runs a baysplinePSM object
            %
            % [UK37, R] = obj.run(SSTs)
            %
            % ----- Inputs -----
            %
            % SSTs: The SSTs used to run the PSM. A numeric row vector.
            %
            % ----- Outputs -----
            %
            % UK37: A row vector of UK37 estimates. A vector.
            %
            % R: Error-variance uncertainty estimated from the posterior.
            %    A vector.
            
            % Currently, there are no additional parameters, so can just
            % call the static method directly.
            [UK, R] = baysplinePSM.run(SSTs);
        end
    end
end