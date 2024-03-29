function[] = tests
%% dash.tests  Implements unit testing for the dash package
% ----------
%   dash.tests
%   Runs the units tests. If the tests pass, exits silently.
%   If the tests fail, prints the first failed test to the console.
% ----------
%
% <a href="matlab:dash.doc('dash.tests')">Documentation Page</a>

% Functions
haversine;

% User utilities
dash.closest.tests;

% Input check utilities
dash.is.tests;
dash.parse.tests;
dash.assert.tests;

% Utility packages
dash.file.tests;
dash.indices.tests;
dash.string.tests;

% Notification packages
dash.warning.tests;
dash.error.tests;

% Classes
dash.dataSource.tests;
dash.gridfileSources.tests;
dash.stateVectorVariable.tests;
dash.ensembleFilter.tests;
dash.posteriorCalculation.tests;

end