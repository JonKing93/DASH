classdef weightedMean < dash.posteriorCalculation.Interface
    %% dash.posteriorCalculation.weightedMean  Calculates a weightedMean on each member of a posterior ensemble
    % ----------
    % weightedMean methods:
    %   weightedMean    - Creates a new weighted mean index calculation object
    %   outputName      - Returns the name of the output field for the weighted mean
    %   outputSize      - Indicates that output has a size of nMembers x nTime
    %   calculate       - Calculates a weighted mean for each member of a posterior ensemble
    %
    % <a href="matlab:dash.doc('dash.posteriorCalculation.weightedMean')">Documentation Page</a>

    properties (Constant)
        timeDim = 2;    % The time dimension of the output array
    end
    properties (SetAccess = private)
        name;       % The user-specified name of the index
        rows;       % State vector rows to use in a mean
        weights;    % Weights to use for a mean
        nanflag;    % Whether to include or exclude NaN elements
    end

    methods (Static)
        function[siz] = outputSize(~, ~, nMembers, nTime)
            %% dash.posteriorCalculation.weightedMean.outputSize  Return the size of the output
            % ----------
            %   siz = obj.outputSize(~, nMembers, nTime)
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
            % <a href="matlab:dash.doc('dash.posteriorCalculation.weightedMean.outputsize')">Documentation Page</a> 
            siz = [nMembers, nTime];
        end
    end

    methods
        function[name] = outputName(obj)
            %% dash.posteriorCalculation.weightedMean.outputName  Return the name of the output field for weighted mean index
            % ----------
            %   name = obj.outputName
            %   Returns a name for the output field for the weighted mean
            %   index.
            % ----------
            %   Outputs:
            %       name (string scalar): The name for the output field for
            %           the weighted mean index. Uses: index_<name>
            %
            % <a href="matlab:dash.doc('dash.posteriorCalculation.weightedMean.outputName')">Documentation Page</a>
            name = strcat("index_", obj.name);
        end
        function[index] = calculate(obj, Adev, Amean)
            %% dash.posteriorCalculation.weightedMean.calculate  Calculate a weighted mean index over each member in a posterior ensemble
            % ----------
            %   index = obj.calculate(Adev, Amean)
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
        function[obj] = weightedMean(name, rows, weights, nanflag
            %% dash.posteriorCalculation.weightedMean.weightedMean  Create a new weighted mean index calculation object
            % ----------
            %   obj = dash.posteriorCalculation.weightedMean(name, rows, weights, nanflag)
            %   Creates a new calculation object for a weighted mean index.
            %   Assumes that all error checking of inputs occurs in
            %   kalmanFilter.index
            % ----------
            %   Inputs:
            %       name (string scalar): The name for the index
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
            obj.name = name;
            obj.rows = rows;
            obj.weights = weights;
            obj.nanflag = nanflag;
        end
    end
end