function[obj] = metric(obj, type, varargin)
%% optimalSensor.metric  Specify a metric for the optimal sensor
% ----------
%   J = obj.metric
%   Returns the initial metric for the optimal sensor algorithm.
%
%   obj = obj.metric(type, ...)
%   Indicates how the optimal sensor should calculate a test metric from
%   the prior. By default, if the prior has a single state vector row, the
%   optimal sensor will use the prior directly as the metric. Thus, this
%   method is not necessary if you provided the metric directly as the
%   prior. Instead, use this method if the prior contains multiple state
%   vector rows.
%
%   obj = obj.metric('direct')
%   Uses the prior directly as the metric. This is the default behavior
%   when the prior contains a single row. You can only select this option
%   if the prior contains a single row.
%
%   obj = obj.metric('mean')
%   obj = obj.metric('mean', weights)
%   obj = obj.metric('mean', rows)
%   obj = obj.metric('mean', rows, weights)
%   Computes the metric by taking a mean over the prior. Optionally only
%   takes the mean over specified rows. Optionally implements a weighted
%   mean over the prior or selected rows.
% ----------
%   Inputs:
%       tpye

