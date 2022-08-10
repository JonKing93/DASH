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
    % ----------
    % Interface Methods:
    %
    % Interface:
    %   outputSize  - Indicates the size of the output array
    %   calculate   - Performs the calculation on a set of ensemble deviations
    %
    % <a href="matlab:dash.doc('dash.posteriorCalculation.Interface')">Documentation Page</a>

    properties (Abstract, Constant)
        timeDimension;  % The time dimension of the output array
    end

    methods (Abstract)

        % dash.posteriorCalculation.Interface.outputSize  Return the size of the outputs of a calculation
        % ----------
        %   siz = <strong>obj.outputSize</strong>(nState, nMembers, nTime)
        %   Determines the size of the calculation's output given the length
        %   of the state vector, number of ensemble members, and number of
        %   assimilation time steps.
        % ----------
        %   Inputs:
        %       nState (scalar positive integer): The length of the state vector
        %       nMembers (scalar positive integer): The number of ensemble members
        %       nTime (scalar positive integer): The number of assimilation time steps
        %
        %   Outputs:
        %       siz (numeric vector): The size of the calculation output
        %
        % <a href="matlab:dash.doc('dash.posteriorCalculation.Interface.outputSize')">Documentation Page</a>
        siz = outputSize(obj, nState, nMembers, nTime);

        % dash.posteriorCalculation.Interface.calculate  Performs a calculation using the update ensemble mean and deviations
        % ----------
        %   value = <strong>obj.calculate</strong>(Adev, Amean)
        %   Performs a calculation using the updated ensemble deviations
        %   and mean. Returns the result of the calculation.
        % ----------
        %   Inputs:
        %       Adev (numeric matrix [nState x nMembers]): An updated set
        %           of ensemble deviations
        %       Amean (numeric matrix [nState x nTime]): The updated
        %           ensemble mean in all time steps that use the updated
        %           set of ensemble deviations
        %
        %   Outputs:
        %       value (numeric array): The result of the calculation. The
        %           size of the value should match the size indicated by
        %           the "outputSize" method.
        %
        % <a href="matlab:dash.doc('dash.posteriorCalculation.Interface.calculate')">Documentation Page</a>
        value = calculate(obj, Adev, Amean);
    end
end
