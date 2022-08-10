function[] = tests
%% dash.ensembleFilter.tests  Unit tests for the dash.ensembleFilter class
% ----------
%   dash.ensembleFilter.tests
%   Runs the unit tests. If succesful, exits silently. Otherwise, throws an
%   error at the first failed test.
% ----------
% 
% <a href="matlab:dash.doc('dash.ensembleFilter.tests')">Documentation Page</a>


constructor;
label;
name;
finalize;

observations;
prior;
estimates;
uncertainties;

assertValidR;
processWhich;

Rcovariance;
loadPrior;

end