function[varargout] = evolvingLabels(obj, varargin)
%% ensemble.evolvingLabels  Set or return labels for an evolving ensemble
% ----------
%   labels = <strong>obj.evolvingLabels</strong>
%   labels = <strong>obj.evolvingLabels</strong>(-1)
%   labels = <strong>obj.evolvingLabels</strong>(e)
%   Returns the labels for the specified ensembles in an evolving ensemble.
%   If ensembles are not specified or -1, returns the labels for all
%   ensembles in the evolving set. Note that evolving labels are distinct
%   from any global label for the ensemble object. These evolving labels
%   reference the individual ensembles in an evolving set. Global labels --
%   accessed via the "ensemble.label" command -- refer instead to the
%   ensemble object.
%
%   obj = <strong>obj.evolvingLabels</strong>(newLabels)
%   Applies new labels to each of the ensembles in the evolving set.
%
%   obj = <strong>obj.evolvingLabels</strong>(-1, newLabels)
%   obj = <strong>obj.evolvingLabels</strong>(e, newLabels)
%   obj = <strong>obj.evolvingLabels</strong>(labels, newLabels)
%   Applies new labels to the specified ensembles in an evolving ensemble.
% ----------
%   Inputs:
%       newLabels (string vector): The new labels to apply to the specified
%           ensembles. Must have one element per indicated ensemble.
%       e (-1 | logical vector | vector, linear indices): -1): The indices
%           specific ensembles within an evolving ensemble. If -1, selects
%           all ensembles within the evolving set. If a logical vector,
%           must have one element per ensemble in the evolving set. If
%           using linear indices and applying new labels, then e cannot
%           contain duplicate values.
%       labels (string vector): The current labels of ensembles in
%           the evolving set. Cannot contain duplicate values. You can only
%           use current labels to reference ensemble that have unique
%           labels in the evolving set. If multiple ensembles share the
%           same label, reference them using indices instead.
%
%   Outputs:
%       labels (string vector): The labels of the specified ensembles in
%           the evolving set.
%       obj (scalar ensemble object): The ensemble object with updated
%           labels for the ensembles in the evolving set.
%
% <a href="matlab:dash.doc('ensemble.evolvingLabels')">Documentation Page</a>

% Setup
header = "DASH:ensemble:evolvingLabels";
dash.assert.scalarObj(obj, header);

% Parse the inputs
nInputs = numel(varargin);
if nInputs>2
    dash.error.tooManyInputs;

% Setting all labels
elseif nInputs==1 && dash.is.string(varargin{1})
    e = -1;
    labels = varargin{1};
    returnValues = false;

% Returning labels
elseif nInputs < 2
    e = -1;
    if nInputs==1
        e = varargin{1};
    end
    returnValues = true;

% Setting some labels
else
    e = varargin{1};
    labels = varargin{2};
    returnValues = false;
end

% Check evolving ensemble indices
e = obj.evolvingIndices(e, returnValues, header);

% Return values
if returnValues
    varargout = {obj.evolvingLabels_(e)};

% If setting values, error check labels
else
    labels = dash.assert.strlist(labels, 'labels', header);

    % Require one label per listed ensemble
    nEnsembles = numel(e);
    nLabels = numel(labels);
    if nLabels ~= nEnsembles
        wrongNumberLabelsError(nLabels, nEnsembles, header);
    end

    % Update the labels
    obj.evolvingLabels_(e,:) = labels;
    varargout = {obj};
end

end

% Error message
function[] = wrongNumberLabelsError(nLabels, nEnsembles, header)
id = sprintf("%s:wrongNumberLabels", header);
ME = MException(id, ['You must provide one label per ensemble (%.f), ',...
    'but you have provided %.f labels instead.'], nEnsembles, nLabels);
throwAsCaller(ME);
end