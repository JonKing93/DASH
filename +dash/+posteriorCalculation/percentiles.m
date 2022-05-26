classdef percentiles < dash.posteriorCalculation.Interface
    %% dash.posteriorCalculation.percentiles  Calculates percentiles across a posterior ensemble
    % ----------
    % percentiles methods:
    %   percentiles - Creates a new ensemble percentiles calculation object
    %   outputSize  - Indicates that output has a size of nState x nPercs x nTime
    %   calculate   - Calculates percentiles across posterior ensembles
    %
    % <a href="matlab:dash.doc('dash.posteriorCalculation.percentiles')">Documentation Page</a>

    properties (Constant)
        timeDim = 3;    % The location of the time dimension in the output array
    end
    properties (SetAccess = private)
        percentages;   % The queried percentiles
    end

    methods
        function[siz] = outputSize(obj, nState, ~, nTime)
            %% dash.posteriorCalculation.percentiles.outputSize  Return the size of the percentiles output
            % ----------
            %   siz = obj.outputSize(nState, ~, nTime)
            %   Returns the size of the output array for the posterior
            %   percentiles, which is nState x nPercs x nTime.
            % ----------
            %   Inputs:
            %       nState (scalar positive integer): The number of state
            %           vector elements for a Kalman filter.
            %       nTime (scalar positive integer): The number of
            %           assimiltion time steps for a Kalman filter. 
            %
            %   Outputs:
            %       siz (vector, positive integers [3]): The size of the
            %           output array. First element is nState, second element
            %           is nPercs, third element is nTime
            %
            % <a href="matlab:dash.doc('dash.posteriorCalculation.percentiles.outputsize')">Documentation Page</a> 
            nPercs = numel(obj.percentiles_);
            siz = [nState, nPercs, nTime];
        end
        function[Aperc] = calculate(obj, Adev, Amean)
            %% dash.posteriorCalculation.percentiles.calculate  Calculate percentiles across a set of ensemble deviations
            % ----------
            %   Aperc = obj.calculate(Adev, Amean)
            %   Calculates percentiles across a set of ensemble deviations.
            %   Propagates the deviation percentiles across posterior means
            %   in order to propagate percentiles across multiple
            %   assimilation time steps.
            % ----------
            %   Inputs:
            %       Adev (numeric matrix [nState x nMembers]): A set of
            %           updated ensemble deviations.
            %       Amean (numeric matrix [nState x nTime]): The updated
            %           ensemble mean for all time steps using the same
            %           deviations.
            %
            %   Outputs:
            %       Aperc (numeric matrix [nState x nPerc x nTime]): The
            %           percentiles of the posterior ensembles that share
            %           the same set of deviations.
            %
            % <a href="matlab:dash.doc('dash.posteriorCalculation.percentiles.calculate')">Documentation Page</a> 

            % Get deviation percentiles
            Aperc = prctile(Adev, obj.percentages, 2);

            % Propagate over means from different time steps
            Aperc = Aperc + permute(Amean, [1 3 2]);
        end
        function[obj] = percentiles(percentages)
            %% dash.posteriorCalculation.percentiles.percentiles  Create a new ensemble percentile calculation object
            % ----------
            %   obj = dash.posteriorCalculation.percentiles(percentages)
            %   Creates a posterior percentile calculation object for the
            %   requested ensemble percentiles. Assumes that all error
            %   checking occurs in kalmanFilter.percentiles
            % ----------
            %   Inputs:
            %       percentages (numeric vector): The percentages for which to
            %           compute percentiles. All values must be on the
            %           interval 0 <= percs <= 100.
            %
            %   Outputs:
            %       obj (scalar percentiles object): A new percentiles
            %           object for the specified percentages.
            %
            % <a href="matlab:dash.doc('dash.posteriorCalculation.percentiles.percentiles')">Documentation Page</a> 
            obj.percentages = percentages;
        end
    end
end