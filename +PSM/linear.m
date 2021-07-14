function[obj] = linear(varargin)
%% Creates a new linear PSM
%
% obj = linear(rows, slopes, intercept)
% Creates a linear PSM using a specified set of slopes and an
% intercept.
%
% obj = linear(rows, slopes, intercept, name)
% Optionally names the PSM
%
% obj = linear(rows, slope, ...)
% Uses the same slope for all variables.
%
% obj = linear(rows, slopes)
% Uses a default intercept of 0.
%
% ----- Inputs -----
%
% rows: A list of state vector rows that indicate the data 
%    values required to run the PSM. A vector of positive
%    integers.
%
% slopes: The slopes for each variable. A numeric vector in the
%    order as the listed rows.
%
% intercept: The intercept for the linear equation. A numeric
%    scalar.
%
% name: An optional name for the PSM. A string
%
% ----- Outputs -----
%
% obj: The new linearPSM object

obj = PSM.linearPSM(varargin{:});

end
            
            

