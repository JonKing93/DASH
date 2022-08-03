classdef variance < dash.posteriorCalculation.Interface
    %% dash.posteriorCalculation.variance  Calculates variance across a posterior ensemble
    % ----------
    % variance methods:
    %   outputSize  - Indicates that output has a size of nState x nTime
    %   calculate   - Calculates variance across posterior ensembles
    %
    % <a href="matlab:dash.doc('dash.posteriorCalculation.variance')">Documentation Page</a>

    properties (Constant)
        timeDimension = 2;    % The time dimension of the output array
    end

    methods
        function[siz] = outputSize(~, nState, ~, nTime)
            %% dash.posteriorCalculation.variance.outputSize  Return the size of the variance output
            % ----------
            %   siz = obj.outputSize(nState, ~, nTime)
            %   Returns the size of the output array for the posterior variance,
            %   which is nState x nTime.
            % ----------
            %   Inputs:
            %       nState (scalar positive integer): The number of state
            %           vector elements for a Kalman filter.
            %       nTime (scalar positive integer): The number of
            %           assimiltion time steps for a Kalman filter. 
            %
            %   Outputs:
            %       siz (vector, positive integers [2]): The size of the
            %           output array. First element is nState, second element
            %           is nTime.
            %
            % <a href="matlab:dash.doc('dash.posteriorCalculation.variance.outputsize')">Documentation Page</a> 
            siz = [nState, nTime];
        end
        function[Avar] = calculate(~, Adev, Amean)
            %% dash.posteriorCalculation.variance.calculate  Calculate the variance across a set of ensemble deviations
            % ----------
            %   Avar = obj.calculate(Adev, Amean)
            %   Calculates the variance across a set of ensemble
            %   deviations. Propagates calculated variances over the number
            %   of assimilation time steps indicated by Amean.
            % ----------
            %   Inputs:
            %       Adev (numeric matrix [nState x nMembers]): A set of
            %           updated ensemble deviations.
            %       Amean (numeric matrix [nState x nTime]): The updated
            %           ensemble mean for all time steps using the same
            %           deviations.
            %
            %   Outputs:
            %       Avar (numeric matrix [nState x nTime]): The variance
            %           across the ensemble deviations, propagated over all
            %           associated assimilation time steps. The columns of
            %           Avar are all identical.
            %
            % <a href="matlab:dash.doc('dash.posteriorCalculation.variance.calculate')">Documentation Page</a> 

            % Determine sizes
            nMembers = size(Adev, 2);
            nTime = size(Amean, 2);

            % Compute variance
            unbias = dash.math.unbias(nMembers);
            Avar = dash.math.variance(Adev, unbias);

            % Replicate over all time steps
            Avar = repmat(Avar, [1, nTime]);
        end
    end
end