classdef weightedMean < dash.posteriorCalculation.Interface
    %% dash.posteriorCalculation.weightedMean  Calculates a weightedMean on each member of a posterior ensemble
    % ----------
    % weightedMean Methods:
    %
    % General:
    %   weightedMean    - Creates a new weighted mean index calculation object
    %   outputSize      - Indicates that output has a size of nMembers x nTime
    %   calculate       - Calculates a weighted mean for each member of a posterior ensemble
    %
    % <a href="matlab:dash.doc('dash.posteriorCalculation.weightedMean')">Documentation Page</a>

    properties (Constant)
        timeDimension = 2;    % The time dimension of the output array
    end
    properties (SetAccess = private)
        rows;       % State vector rows to use in a mean
        weights;    % Weights to use for a mean
        nanflag;    % Whether to include or exclude NaN elements
    end

    methods
        function[siz] = outputSize(~, ~, nMembers, nTime)
            %% dash.posteriorCalculation.weightedMean.outputSize  Return the size of the output
            % ----------
            %   siz = <strong>obj.outputSize</strong>(~, nMembers, nTime)
            %   Returns the size of the output array for a weighted mean
            %   calculated over ensemble members, which is nMembers x nTime
            % ----------
            %   Inputs:
            %       nMembers (scalar positive integer): The number of 
            %           ensemble members for a Kalman filter.
            %       nTime (scalar positive integer): The number of
            %           assimiltion time steps for a Kalman filter. 
            %
            %   Outputs:
            %       siz (vector, positive integers [2]): The size of the
            %           output array. First element is nMembers, second element
            %           is nTime.
            %
            % <a href="matlab:dash.doc('dash.posteriorCalculation.weightedMean.outputSize')">Documentation Page</a> 
            siz = [nMembers, nTime];
        end
        function[index] = calculate(obj, Adev, Amean)
            %% dash.posteriorCalculation.weightedMean.calculate  Calculate a weighted mean index over each member in a posterior ensemble
            % ----------
            %   index = <strong>obj.calculate</strong>(Adev, Amean)
            %   Calculates a weighted mean index over each member of a 
            %   posterior ensemble. Propagates weighted means for the
            %   deviations over ensemble means for multiple time steps that
            %   share the same deviations.
            % ----------
            %   Inputs:
            %       Adev (numeric matrix [nState x nMembers]): A set of
            %           updated ensemble deviations.
            %       Amean (numeric matrix [nState x nTime]): The updated
            %           ensemble mean for all time steps using the same
            %           deviations.
            %
            %   Outputs:
            %       index (numeric matrix [Members x nTime]): The weighted
            %           mean index calculated over the members of the
            %           posterior ensemble.
            %
            % <a href="matlab:dash.doc('dash.posteriorCalculation.weightedMean.calculate')">Documentation Page</a> 

            % Extract data at the requested rows
            Amean = Amean(obj.rows, :);
            Adev = Adev(obj.rows, :);

            % Note that, because of the matrix decompositions in
            % kalmanFilter.run, Amean and Adev will have the same NaN
            % rows, and any row with NaN will be all NaN.

            % Get the weights and denominator.
            w = obj.weights;
            nans = isnan(Amean(:,1));
            w(nans) = NaN;
            denom = sum(w, 'omitnan');

            % Propagate the weighted sum over mean and deviations
            devSum = sum(w.*Adev, 1, obj.nanflag) ./ denom;
            meanSum = sum(w.*Amean, 1, obj.nanflag) ./ denom;
            index = devSum' + meanSum;
        end
        function[obj] = weightedMean(rows, weights, nanflag)
            %% dash.posteriorCalculation.weightedMean.weightedMean  Create a new weighted mean index calculation object
            % ----------
            %   obj = <strong>dash.posteriorCalculation.weightedMean</strong>(rows, weights, nanflag)
            %   Creates a new calculation object for a weighted mean index.
            %   Assumes that all error checking of inputs occurs in
            %   kalmanFilter.index
            % ----------
            %   Inputs:
            %       rows (vector, linear indices): The state vector rows
            %           used in the mean
            %       weights (numeric vector [nRows]): Weights for a
            %           weighted mean
            %       nanflag ('includenan' | 'omitnan'): How to treat NaN
            %           values in a weighted mean
            %
            %   Outputs:
            %       obj (scalar weightedMean object): The new weighted mean
            %           index calculation object
            %
            % <a href="matlab:dash.doc('dash.posteriorCalculation.weightedMean.weightedMean')">Documentation Page</a> 
            obj.rows = rows;
            obj.weights = weights;
            obj.nanflag = nanflag;
        end
    end
end