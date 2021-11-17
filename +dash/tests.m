function[] = tests
%% dash.tests Implements unit testing for the dash package
% ----------
%   dash.tests
%   Runs the units tests. If the tests pass, exits silently.
%   If the tests fail, prints the first failed test to the console.
% ----------
%
% <a href="matlab:dash.doc('dash.tests')">Documentation Page</a>

% dash.gridfileSources.tests;
% dash.assert.tests;
dash.dataSource.tests;
dash.file.tests;
dash.indices.tests;
dash.is.tests;
dash.parse.tests;
dash.string.tests;

end