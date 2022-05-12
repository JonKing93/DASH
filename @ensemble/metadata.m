function[metadata] = metadata(obj, ensembles)
%% ensemble.metadata  Return the ensembleMetadata object for a saved ensemble
% ----------
%   metadata = obj.metadata
%   Returns the metadata for the variables and ensemble members being used
%   by the ensemble. Variables and ensemble members that are not used by
%   the ensemble are not in the metadata. Essentially, this method returns
%   metadata for the ensemble that will be loaded when the "ensemble.load"
%   command is used. If the ensemble implements a static ensemble, the
%   output will be a scalar ensembleMetadata object. If the ensemble
%   implements an evolving ensembleMetadata object, then the output will be
%   a vector of ensembleMetadata objects with one element per ensemble in
%   the evolving set.
%
%   metadata = obj.metadata(labels)
%   metadata = obj.metadata(e)
%   metadata = obj.metadata(-1)
%   Returns the metadata for the specified ensembles in an evolving set.
%   The output will be a vector of ensembleMetadata objects with one
%   element per specified ensemble. If the input is -1, returns the
%   metadata for all ensembles in the evolving set.
%
%   metadata = obj.metadata(0)
%   Returns the ensembleMetadata object for the ensemble saved in the .ens
%   file. This object includes metadata for all variables and ensemble
%   members saved in the file, regardless of whether they are used by the
%   ensemble object.
% ----------

% Setup
header = "DASH:ensemble:metadata";
dash.assert.scalarObj(obj, header);

% Default
if ~exist('ensembles','var')
    ensembles = -1;
end

% If 0, return the full metadata object
if isequal(ensembles, 0)
    metadata = obj.metadata_;

% Otherwise, parse requested ensembles
else
    ensembles = obj.evolvingIndices(ensembles, true, header);
    nEnsembles = numel(ensembles);

    % Extract used variables
    variables = obj.variables;
    metadata = obj.metadata_.extract(variables);

    % Preallocate metadata vector
    metadata = repmat(metadata, nEnsembles, 1);

    % Extract ensemble members for each metadata
    for k = 1:nEnsembles
        e = ensembles(k);
        members = obj.members_(:,e);
        metadata(k) = metadata(k).extractMembers(members);
    end
end

end