function[output] = run(obj, varargin)
%% particleFilter.run  Runs an offline particle filter assimilation
% ----------
%   output = obj.run
%   Runs the offline particle filter assimilation. Returns the updated
%   state vector and particle weights for each assimilated time step.
%   Requires the particle filter object to have observations, estimates,
%   uncertainties, and a prior.
%
%   If you would like details on the implementation of the algorithm, or
%   for advice on troubleshooting large state vectors, please see the help
%   text for the particleFilter class:
%     >> help particleFilter
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
    obj = obj.finalize(true, 'running a particle filter', header);
end

% Parse the SSE option
returnSSE = dash.parse.nameValue(varargin, "sse", {false}, 0, header);
switches = {["discard","d"], ["return","r"]};
returnSSE = dash.parse.switches(returnSSE, switches, 1, ...
                                 'returnSSE', 'recognized option', header);

% Initialize output
output = struct;
try
    output.A = NaN([obj.nState, obj.nTime], obj.precision);
catch
    outputTooLargeError(obj, header);
end

% Compute the particle weights. Optionally record SSE values
[weights, sse] = obj.computeWeights;
output.weights = weights;
if returnSSE
    output.sse = sse;
end

% Get the time steps associated with each prior
for p = 1:obj.nPrior
    t = find(obj.whichPrior == p);

    % Load the prior, informative error if failed to load
    try
        X = obj.loadPrior(p);
    catch cause
        priorFailedError(obj, p, cause, header);
    end

    % Update the state vector
    output.A(:,t) = X * weights(:,t);
end

end

%% Error message
function[] = priorFailedError(obj, p, cause, header)

% Too large to fit in memory
if strcmp(cause.identifier, "DASH:ensemble:load:priorTooLarge")
    if p == 1
        name = 'the prior';
    else
        name = sprintf('prior %.f', p);
    end
    link = '<a href="matlab:doc matfile">matfile</a>';
    id = sprintf('%s:arrayTooLarge', header);
    ME = MException(id, ['Cannot run %s because %s is too large ',...
        'to load into memory. It''s useful noting that the updates for each state ',...
        'vector element are independent of all the other state vector elements. Thus, ',...
        'you can often circumvent memory issues by dividing the state vector ',...
        'into sevearl smaller peices, and running the particle filter on ',...
        'each piece individually. The built-in %s command can be ',...
        'particularly helpful for saving/loading pieces of large arrays sequentially.'],...
        obj.name, name, link);
    ME = addCause(ME, cause);
    throwAsCaller(ME);

% Other DASH errors - likely an issue with the ensemble's matfile
elseif startsWith(cause.identifier, 'DASH')
    if obj.nPrior == 1
        name = 'the prior';
    else
        name = sprintf('prior %.f', p);
    end
    id = sprintf('%s:priorFailed', header);
    ME = MException(id, 'Cannot run %s because %s failed to load.', obj.name, name);
    ME = addCause(ME, cause);
    throwAsCaller(ME);

% Anything else is an true error, pass it along
else
    rethrow(cause);
end

end
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