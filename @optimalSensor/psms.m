function[obj] = psms(obj, F, R)
%% Specify PSMs and uncertainties for an optimal sensor test
%
% obj = obj.psms(psms, R)
%
% ----- Inputs -----
%
% psms: A set of PSMs. Either a scalar PSM object or a cell
%    vector whose elements are PSM objects.
%
% R: Observation uncertainty for each PSM. A numeric vector with one
%    element per PSM. If an element of R is NaN, the optimal sensor will
%    attempt to determine uncertainty using the PSM.
%
% ----- Outputs -----
%
% obj: The updated optimalSensor object

% Error check the ensemble and psms
assert(~isempty(obj.X), 'You must specify a prior before you provide PSMs');
assert(isempty(obj.Ye), 'You cannot specify PSMs because you already provided estimates');

% Error check the uncertainties
nSite = numel(F);
dash.assertVectorTypeN(R, 'numeric', nSite, 'R');
dash.assertRealDefined(R, 'R', true);
assert(~any(R<=0), 'R can only include positive values');

% Error check the PSMs
F = PSM.setupEstimate(obj.X, F);

% Save
obj.F = F;
obj.R = R;
obj.nSite = nSite;
obj.hasPSMs = true;

end