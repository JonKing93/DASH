classdef (Abstract) Interface
    %% dash.posteriorCalculation.Interface  Interface for objects that perform calculations on posterior deviations
    % ----------
    %   This class is an abstract interface. It provides a framework for
    %   classes to perform calculations that require the posterior
    %   deviations from a Kalman filter. The purpose of this class is to
    %   allow developers to plug-in new calculations into the Kalman
    %   filter, without requiring them to know the inner workings of the
    %   "kalmanFilter.run" method.
    %
    %   In particular, this Interface is inteded to help extend the
    %   "kalmanFilter.index" command for climate indices that are
    %   calculated using a variety of methods. The interface is also used 
    %   by the classes that calculate ensemble variance and percentiles.
    %
    %   The interface has several requirements:
    %   1. Calculations must also include an "outputSize" method that
    %      indicates the size of the output arrays resulting from the
    %      calculations. This allows "kalmanFilter.run" to preallocate
    %      output for these calculations
    %   2. Calculations must implement a "calculate" method that performs
    %      the calculation on a set of ensemble deviations and optionally
    %      also the ensemble mean.
    %   3. Calculations must indicate which dimension of output the output
    %      array corresponds to assimilation time steps. This allows the 
    %      Kalman filter to record calculated output for different time
    %      steps. 
    %   4. Calculations must implement an "outputName" property which
    %      indicates the name the kalman filter should assign the output
    %      field for the calculation.
    % ----------
    % Interface properties:
    %   timeDim     - The index of the time dimension in the calculation output
    %
    % Interface methods:
    %   outputSize  - Indicates the size of the output array
    %   outputName  - Indicates the name of the output field
    %   calculate   - Performs the calculation on a set of ensemble deviations
    %
    % <a href="matlab:dash.doc('dash.posteriorCalculation.Interface')>Documentation Page</a>

    properties (Abstract, Constant)
        timeDim;  % The time dimension of the output array
    end

    methods (Abstract)
        siz = outputSize(obj, nState, nMembers, nTime);
        name = outputName(obj);
        value = calculate(obj, Adev, Amean);
    end
end
