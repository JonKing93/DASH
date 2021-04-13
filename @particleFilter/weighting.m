function[pf] = weighting(pf, type, N)
%% Select the weighting scheme for a particle filter
%
% pf = pf.weighting('bayes')
% The posterior is computed as the weighted mean of all particles.
% Particles weights are calculated using Bayes' theorem. This is the
% default weighting scheme.
%
% pf = pf.weighting('best', N)
% Computes the posterior using the average of the best N particles in each
% time step.
%
% ----- Inputs -----
%
% N: The number of particles used to compute the posterior
%
% ----- Outputs -----
%
% pf: The updated particleFilter object

% Error check and save the weighting type
type = dash.assertStrFlag(type, 'type');
assert(any(strcmpi(type, ["best","bayes"])), 'The weighting scheme must either be "best" or "bayes"');

% Error check and set up "bayes" scheme
if strcmpi(type, "bayes")
    assert(nargin==2, 'The "bayes" weighting scheme does not use additional input arguments');
    pf.weightType = 0;
    pf.weightArgs = [];

% Error check "best" scheme number. Require a scalar integer within the
% number of ensemble members
elseif strcmpi(type, "best")
    assert(isscalar(N), 'N must be a scalar');
    dash.assertPositiveIntegers(N, 'N');
    assert(N<=pf.nEns, sprintf('N cannot be larger than the number of ensemble members (%.f)', pf.nEns));
    
    pf.weightType = 1;
    pf.weightArgs = N;
end

end