function[output] = run(obj, varargin)
%% particleFilter.run  Runs an offline particle filter assimilation
% ----------
%   output = obj.run
%   Runs the offline particle filter assimilation. Returns the updated
%   state vector and particle weights for each assimilated time step.
%   Requires the particle filter object to have observations, estimates,
%   uncertainties, and a prior.
%
%   The following is a brief sketch of the particle filter algorithm:
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
%
%   output = obj.run(..., 'sse', returnSSE)
%   output = obj.run(..., 'sse', "return"|"r"|true)
%   output = obj.run(..., 'sse', "discard"|"d"|false)
%   Indicate whether to include the sum of squared errors for each particle
%   in the output. Default behavior is to not include the SSE values in the
%   output. Use "return"|"r"|true to return these values.
% ----------
%   Inputs:
%       returnSSE (string scalar | scalar logical): Indicates whether to
%           return the sum of squared errors for each particle in the output.
%           ["return"|"r"|true]: Returns the SSE values in the output
%           ["discard"|"d"|false (default)]: Does not return SSE values
%
%   Outputs:
%       output (scalar struct): Output produced by the particle filter.
%           May include the following fields:
%           .A  (numeric matrix [nState x nTime]): The updated state vector
%               for each assimilated time step. A numeric matrix, each
%               column holds the updated state vector for an assimilated time step.
%           .weights (numeric matrix [nMembers x nTime]): The particle 
%               weights of each ensemble member for each assimilated time 
%               step. A numeric matrix. Each row holds the weights of a
%               specific ensemble member, and each column holds the weights
%               for an assimilated time step.
%           .sse (numeric matrix [nMembers x nTime]): The SSE values for a
%               particle filter. Each row holds the weights for a particular
%               ensemble member. Each column holds weights for an assimilation
%               time step. Lower values indicate greater similarity to the proxy
%               observations.
%
% <a href="matlab:dash.doc('particleFilter.run')">Documentation Page</a>

% Setup
header = "DASH:particleFilter:run";
dash.assert.scalarObj(obj, header);

% Require a finalized filter
if ~obj.isfinalized
    obj = obj.finalize;
end

% Parse the SSE option
returnSSE = dash.parse.nameValue(varargin, "sse", {false}, 0, header);

% Initialize output
output = struct;
try
    output.A = NaN([obj.nState, obj.nTime], obj.priorPrecision);
catch
    outputTooLargeError(obj, header);
end

% Compute the particle weights. Optionally record SSE values
[weights, sse] = obj.computeWeights;
output.weights = weights;
if returnSSE
    output.sse = sse;
end

% Update the state vector
for p = 1:obj.nPrior
    t = find(obj.whichPrior == p);
    X = obj.loadPrior(p);
    output.A(:,t) = X * weights(:,t);
end

end

%% Error message
function[] = outputTooLargeError(obj, header)
siz = [obj.nState, obj.nTime];
link = '<a href="matlab:doc matfile">matfile</a>';
id = sprintf('%s:outputTooLarge', header);
ME = MException(id, ['The output array for the updated state vector is too large to fit in ',...
    'memory (Size: %s). Since the update for each state vector row is independent of all ',...
    'the other rows, you may want to consider running the particle filter on ',...
    'a few rows of the state vector at a time. The %s command may be useful ',...
    'for saving/loading pieces of a state vector sequentially.'],...
    dash.string.size(siz), link);
throwAsCaller(ME);
end