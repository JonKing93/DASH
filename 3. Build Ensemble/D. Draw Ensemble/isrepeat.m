function[ir] = isrepeat( A, varargin )
%% Determines whether or not elements are repeated in a vector. The first
% occurrence of an element is NOT considered a repeat.
%
% C = isRepeat( A, uniqArgs )
%
% ----- Inputs -----
%
% A: Values
%
% uniqArgs: Arguments for the unique function
%
% ----- Outputs -----
%
% C: A Logical array for whether each element is a repeat.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Find the unique elements
[~,ia,ic] = unique(A, varargin{:});

% Get the set of all indices
allIndex = (1:numel(ic))';

% Get the indices that were not unique
ir = ~ismember( allIndex, ia );

end