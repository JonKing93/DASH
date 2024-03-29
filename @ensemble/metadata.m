function[metadata] = metadata(obj, ensembles)
%% ensemble.metadata  Return the ensembleMetadata object for a saved ensemble
% ----------
%   metadata = <strong>obj.metadata</strong>
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
%   metadata = <strong>obj.metadata</strong>(labels)
%   metadata = <strong>obj.metadata</strong>(e)
%   metadata = <strong>obj.metadata</strong>(-1)
%   Returns the metadata for the specified ensembles in an evolving set.
%   The output will be a vector of ensembleMetadata objects with one
%   element per specified ensemble. If the input is -1, returns the
%   metadata for all ensembles in the evolving set.
%
%   metadata = <strong>obj.metadata</strong>(0)
%   Returns the ensembleMetadata object for the ensemble saved in the .ens
%   file. This object includes metadata for all variables and ensemble
%   members saved in the file, regardless of whether they are used by the
%   ensemble object.
% ----------
%   Inputs:
%       e (0 | -1 | logical vector | vector, linear indices): If 0, returns
%           the metadata for the data saved in the .ens file. Otherwise,
%           indicates which ensembles in the evolving set to return metadata
%           for. If -1, selects all evolving ensembles. If a logical
%           vector, must have one element per evolving ensemble.
%       labels (string vector [nEvolving]): The labels of ensembles in an
%           evolving set. You can only use labels to refer to ensembles
%           that have unique labels. If multiple ensembles share the same
%           label, reference them using ensemble indices instead.
%
%   Outputs:
%       metadata (vector, ensembleMetadata objects): The ensembleMetadata
%           objects for the indicated ensembles. Has one element per listed
%           ensemble. Each metadata object holds information on the used
%           variables and ensemble members for a particular ensemble.
%
% <a href="matlab:dash.doc('ensemble.metadata')">Documentation Page</a>

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

        % Label each metadata
        if obj.isevolving
            metadata(k) = metadata(k).label(obj.evolvingLabels(k));
        else
            metadata(k) = metadata(k).label(obj.label);
        end
    end
end

end