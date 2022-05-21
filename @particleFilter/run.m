function[output] = run(obj)
%% particleFilter.run  Runs an offline particle filter assimilation
% ----------
%   output = obj.run
%   Runs the offline particle filter assimilation. Requires the particle
%   filter object to have observations, estimates, uncertainties, and a
%   prior. The following is a brief sketch of the particle filter
%   algorithm:
%
%   For a given assimilated time step, the method begins by calculating the
%   innovations between the observations and estimates. The innovatios are
%   then weighted by the R uncertainties. The method then computes the sum
%   of the weighted innovations for each ensemble member. The result is the
%   sum of squared errors (SSE) for each ensemble member - the SSE values
%   measure the similarity of each ensemble member to the observations.
%   Next, the method applies a weighting scheme to the SSE values to
%   determine a weight for each ensemble member (the weight for each 
%   particle). Finally, the method uses these particle weights to take a
%   weighted mean across the ensemble. The final weighted mean is the
%   updated state vector for that time step.
% ----------
%   Outputs:
%       output (scalar struct): Output produced by the particle filter
%           .A  (numeric matrix [nState x nTime]): The updated state vector
%               for each assimilated time step. A numeric matrix, each
%               column holds the state vector for an assimilated time step.
%           .weights (numeric matrix [nMembers x nTime]): The particle 
%               weights of each ensemble member for each assimilated time 
%               step. A numeric matrix. Each row holds the weights of a
%               specific ensemble member, and each column holds the weights
%               for an assimilated time step.
%
% <a href="matlab:dash.doc('particleFilter.run')">Documentation Page</a>

% Setup
header = "DASH:particleFilter:run";
dash.assert.scalarObj(obj, header);

% Require a finalized filter
if ~obj.isfinalized
    obj = obj.finalize;
end

% Initialize output
output = struct;
output.A = NaN([obj.nState, obj.nTime], obj.priorPrecision);

% Compute the particle weights
weights = obj.computeWeights;
output.weights = weights;

% Update the state vector
for p = 1:obj.nPrior
    t = find(obj.whichPrior == p);
    X = obj.loadPrior(p);
    output.A(:,t) = X * weights(:,t);
end

end