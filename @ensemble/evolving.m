function[obj] = evolving(obj, varargin)
%% ensemble.evolving  Design evolving ensembles
% ----------
%   obj = obj.evolving(members)
%   Designs a new evolving ensemble. Each column of the "members" input
%   indicates the ensemble members that should be used in a particular
%   ensemble, so the number of evolving ensembles will match the number of
%   columns. If the ensemble object previously implemented an evolving
%   ensemble, the evolving labels will all be reset.
%
%   obj = obj.evolving(members, newLabels)
%   Also applies labels to the ensembles in the evolving ensemble. You must
%   provide one label per evolving ensemble (one label per column of "members").
%   These evolving labels are distinct from any global label applied to the
%   ensemble object. The evolving labels -- accessed via the 
%   "ensemble.evolvingLabels" command -- refer to individual ensembles
%   within the evolving ensemble. By contrast, the global label -- accessed
%   via the "ensemble.label" command -- refers to the ensemble object as a
%   whole.
%
%   obj = obj.evolving(-1, members)
%   obj = obj.evolving(e, members)
%   obj = obj.evolving(labels, members)
%   Replaces the ensemble members used for specific ensembles in an
%   existing evolving ensemble. If the first input is -1, sets new ensemble
%   members for all the ensembles in the current evolving ensemble. Unlike
%   the first syntax, this does not reset the evolving labels. Otherwise,
%   use the indices of ensembles in the evolving ensemble, or the labels of
%   evolving ensembles to replace the members of specific ensembles. Note
%   that you can only use evolving labels to reference ensembles that have
%   unique labels. If you want to replace the members of ensembles with the
%   same evolving label, then you will need to specify those ensembles
%   using their indices.
%
%   obj = obj.evolving(..., members, newLabels)
%   In addition to replacing ensemble members, also updates the evolving
%   labels of the specified ensembles.
%
%   obj = obj.evolving(eNew, members)
%   Adds additional ensembles to an evolving ensemble. As usual, the
%   columns of "members" indicate the ensemble members to use for different
%   ensembles. The first input indicates the indices of these new ensembles
%   within the total set of evolving ensembles. Unlike the "e" input in
%   syntax 3, the "eNew" input may include indices greater than the current
%   number of ensembles in the evolving ensemble, and these indices are
%   used to add new ensembles to the evolving set. The "eNew" input must
%   include all indices on the interval:
%   current number of ensembles + 1 : new number of ensembles
%   The "eNew" input may also include the indices of existing ensembles,
%   and these ensembles will have their ensemble members updated.
%
%   obj = obj.evolving(eNew, members, newLabels)
%   Also applies evolving labels to the new ensembles in the evolving
%   ensemble. If the "eNew" input contains the indices of existing
%   ensembles, updates the labels of those ensembles.
% ----------
%   Inputs:
%       members (matrix, linear indices [nMembers x nEnsembles] | logical [nSavedMembers x nEnsembles]): 
%           The ensemble members to use for the ensembles in an evolving
%           ensemble. Each column indicates the ensemble members to use for
%           a particular ensemble. If using linear indices, each element of
%           "members" lists the index of a particular ensemble member saved
%           in the .ens file. If using logical indices, must have one row
%           per saved ensemble member, and the sum of each column must be
%           the same.
%       e (-1 | logical vector | linear indices): The indices of ensembles
%           in an existing evolving ensemble. If a logical vector, must
%           have one element per ensemble in the evolving set. If a linear
%           vector, cannot include repeat indices. If -1, selects all
%           ensemble members in the current evolving set.
%       eNew (vector, linear indices): The indices of new (and/or existing)
%           ensembles in an evolving ensemble. Must include every index
%           between the current number of ensembles and the new total
%           number of ensembles. Cannot have repeat elements.
%       labels (string vector [nEnsembles]): The current labels of ensembles in the
%           evolving set. Must have one element per column in members and
%           cannot contain duplicate elements. You can only use labels to 
%           reference ensembles that have unique labels. If multiple
%           ensembles in the evolving set share the same label, reference
%           them using indices instead.
%       newLabels (string vector [nEnsembles]): The new labels to apply to
%           the ensembles in an evolving set. Must have one element per
%           column of "members".
%
%   Outputs:
%       obj (scalar ensemble object): The ensemble object with updated
%           evolving ensembles.
%
% <a href="matlab:dash.doc('ensemble.evolving')">Documentation Page</a>

% Setup
header = "DASH:ensemble:evolving";
dash.assert.scalarObj(obj, header);

% Check for allowed number of inputs
nInputs = numel(varargin);
if nInputs==0
    dash.error.notEnoughInputs;
elseif nInputs>3
    dash.error.tooManyInputs;

% Create a new evolving ensemble
elseif nInputs==1 || (nInputs==2 && dash.is.string(varargin{2}))
    obj = resetEvolving(obj, header, varargin{1:end});

% Update an existing evolving ensemble
else
    obj = updateEvolving(obj, header, varargin{1:end});
end

end


%% Subfunctions
function[obj] = resetEvolving(obj, header, members, labels)

% Error check members, convert to linear indices
members = obj.assertEvolvingMembers(members, [], [], 'members', header);
nEnsembles = size(members, 2);

% Default and error check labels
if ~exist('labels','var') || isempty(labels)
    labels = strings(nEnsembles, 1);
else
    labels = dash.assert.strlist(labels, 'newLabels', header);
    nLabels = numel(labels);
    if nLabels~=nEnsembles
        id = sprintf('%s:wrongNumberOfLabels', header);
        error(id, ['You must provide one evolving label per ensemble in the ',...
            'evolving set (%.f), but you have provided %.f labels instead.'],...
            nEnsembles, nLabels);
    end
end

% Record new evolving ensemble
obj.members_ = members;
obj.isevolving = nEnsembles > 1;
obj.evolvingLabels_ = labels(:);

end
function[obj] = updateEvolving(obj, header, ensembles, members, labels)

% Identify whether the ensembles are linear indices
linear = true;
if isequal(ensembles,-1) || islogical(ensembles) || dash.is.string(ensembles)
    linear = false;
elseif ~isnumeric(ensembles)
    id = sprintf('%s:invalidEnsembles', header);
    error(id, ['When selecting ensembles, the first input must be a ',...
        'logical, numeric, or string vector']);
end

% Get ensemble indices when not adding new ensembles
if ~linear
    e = obj.evolvingIndices(ensembles, false, header);

% If linear indices, require unique positive integers
else
    dash.assert.uniqueSet(ensembles, 'ensemble', header);
    e = ensembles;
    [isvalid, bad] = dash.is.positiveIntegers(e);
    if ~isvalid
        id = sprintf('%s:invalidLinearIndices', header);
        error(id, ['The first input is numeric, so it must consist ',...
            'of linear indices (positive integers). However element %.f (%f) is ',...
            'not a positive integer.'], bad, e(bad));
    end
end

% Note if adding new ensembles
addingNew = false;
maxIndex = max(e);
nCurrent = obj.nEvolving;
if maxIndex > nCurrent
    addingNew = true;
end

% If adding new ensembles, require each index on the interval:
%       current number + 1 : new number
if addingNew
    required = nCurrent+1:maxIndex;
    missing = ~ismember(required, e);
    if any(missing)
        id = sprintf('%s:missingEvolvingIndex', header);
        error(id, ['Since you are adding new ensembles to the evolving set ',...
            'the first index must include every index on the interval ',...
            '(%.f:%.f). However, the following indices are missing: %s.'],...
            required(1), required(end), dash.string.list(required(missing)));
    end
end

% Error check members, convert to linear indices
members = obj.assertEvolvingMembers(members, obj.nMembers, numel(e), 'members', header);

% Default and error check labels
if ~exist('labels', 'var')
    labels = strings(nEnsembles, 1);
    haslabel = (e <= nCurrent);
    labels(haslabel) = obj.evolvingLabels_(e(haslabel));
else
    labels = dash.assert.strlist(labels, 'newLabels', header);
    nLabels = numel(labels);
    if nLabels~=nEnsembles
        id = sprintf('%s:wrongNumberOfLabels', header);
        error(id, ['You must provide one label per specified ensemble ',...
            '(%.f), but you have provided %.f labels instead.'],...
            nEnsembles, nLabels);
    end
end

% Update evolving ensemble
obj.members_(:,e) = members;
obj.isevolving = max(nCurrent,maxIndex) > 1;
obj.evolvingLabels_(e,:) = labels(:);

end