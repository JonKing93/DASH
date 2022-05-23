function[obj] = weights(obj, type, varargin)
%% particleFilter.weights  Select the weighting scheme for a particle filter
% ----------
%   obj = obj.weights('bayes')
%   Computes particle filter weights using Bayes's formula. This is the
%   default weighting scheme for the particle filter.
%
%   obj = obj.weights('best', N)
%   Computes particle filter weights to implement an average over the best
%   N particles. The N best particles receive a weight of 1/N, all other
%   particles receive a weight of 0.
% ----------
%   Inputs:
%       N (scalar positive integer): The number of best particles to use
%           when computing the best N weights.
%
%   Outputs:
%       obj (scalar particleFilter object): The particle filter with an
%           updated weighting scheme.
%
% <a href="matlab:dash.doc('particleFilter.weights')">Documentation Page</a>

% Setup
header = "DASH:particleFilter:weights";
dash.assert.scalarObj(obj, header);

% Initial error check, get number of inputs
type = dash.assert.strflag(type, "The first input", header);
nInputs = numel(varargin);

% Bayesian scheme
if strcmpi(type, "bayes")
    if nInputs~=0
        dash.error.tooManyInputs;
    end
    obj.weightType = 0;
    obj.weightArgs = {};

% Best N scheme
elseif strcmpi(type, 'best')
    if nInputs==0
        dash.error.notEnoughInputs;
    elseif nInputs>1
        dash.error.tooManyInputs;
    elseif obj.nMembers == 0
        noMembersError(obj, header)
    end

    % Error check N
    N = varargin{1};
    dash.assert.scalarType(N, 'numeric', 'N', header);
    dash.assert.positiveIntegers(N, 'M', header);
    if N > obj.nMembers
        NTooLargeError;
    end

    % Record values
    obj.weightType = 1;
    obj.weightArgs = {N};
end

end

%% Error messages
function[] = noMembersError(obj, header)
link1 = '<a href="matlab:dash.doc(''particleFilter.prior'')">prior</a>';
link2 = '<a href="matlab:dash.doc(''particleFilter.estimates'')">estimates</a>';
id = sprintf('%s:noMembers', header);
ME = MException(id, ['You cannot apply the "best N" weighting scheme yet, because ',...
    '%s does not have any ensemble members. Before selecting this scheme, ',...
    'use the %s or %s method to set the number of ensemble members.'],...
    obj.name, link2, link1);
throwAsCaller(ME);
end
function[] = NTooLargeError
id = sprintf('%s:NTooLarge', header);
ME = MException(id, 'N cannot be larger than the number of ensemble members (%.f).',obj.nMembers);
throwAsCaller(ME);
end