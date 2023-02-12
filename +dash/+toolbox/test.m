function[] = test
%% dash.toolbox.test  Runs unit tests for the entire DASH toolbox
% ----------
%   dash.toolbox.test
%   Runs the unit tests for the toolbox. If successful, exits silently. If
%   unsuccessful, throws an error at the first failed test.
% ----------
%
% <a href="matlab:dash.doc('dash.toolbox.test')">Documentation Page</a>

dash.tests;
gridMetadata.tests;
gridfile.tests;
% stateVector.tests;
% ensembleMetadata.tests;
% ensemble.tests;
% PSM.tests;
% kalmanFilter.tests;
% particleFilter.tests;
% optimalSensor.tests;

end