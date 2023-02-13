function[] = testToolbox
%% dash.testToolbox  Runs unit tests for the entire DASH toolbox
% ----------
%   dash.testToolbox
%   Runs the unit tests for the toolbox. If successful, exits silently. If
%   unsuccessful, throws an error at the first failed test.
% ----------
%
% <a href="matlab:dash.doc('dash.testToolbox')">Documentation Page</a>

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