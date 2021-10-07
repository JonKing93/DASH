function[] = tests
%% dash.tests Implements unit testing for the dash package
%
%   dash.tests() runs the units tests. If the tests pass, exits silently.
%   If the tests fail, prints the first failed test to the console.
%
%   The following are tested:
%     Subpackages: assert, is

% Subpackages
dash.assert.tests;
dash.is.tests;

end