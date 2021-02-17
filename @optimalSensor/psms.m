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
assert(~isempty(obj.M), 'You must specify a prior before you provide PSMs');
assert(~obj.hasEstimates, 'You cannot specify PSMs because you already provided estimates');
nState = size(obj.M, 1);
F = PSM.checkPSMs(F, nState);

% Error check the uncertainties
nSite = numel(F);
dash.assertVectorTypeN(R, 'numeric', nSite, 'R');
dash.assertRealDefined(R, 'R', true);
assert(~any(R<=0), 'R can only include positive values');

% Save
obj.F = F;
obj.R = R;
obj.nSite = nSite;

end