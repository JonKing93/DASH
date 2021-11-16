function[] = tests
%% dash.tests Implements unit testing for the dash package
% ----------
%   dash.tests
%   Runs the units tests. If the tests pass, exits silently.
%   If the tests fail, prints the first failed test to the console.
% ----------
%   The following are tested:
%     Subpackages: is, indices, assert



%% Subpackages

% Inputs
dash.is.tests;

% Specific types
dash.file.tests;
dash.indices.tests;

end