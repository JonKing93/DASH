function[obj] = update(obj)
%% ensemble.update  Updates an ensemble object to include any new ensemble members added to the .ens file
% ----------
%   obj = obj.update
%   Updates an ensemble object. If ensemble members are added to a .ens
%   file (using the "addMembers" command) after the creation of an ensemble
%   object, the ensemble object will not include the new ensemble members. 
%   Use this method to include the new ensemble members in the ensemble
%   object. This method will not alter the members currently being used by
%   the object - use the "static", "evolving", or "useMembers" commands 
%   after calling the "update" command to include the new members in the 
%   members used by the ensemble object.
% ----------
%   Outputs:
%       obj (scalar ensemble object): The ensemble object with updated
%           information about the members saved in the .ens file.
%
% <a href="matlab:dash.doc('ensemble.update')">Documentation Page</a>

% Setup
header = "DASH:ensemble:update";
dash.assert.scalarObj(obj, header);

% Validate matfile
try
    [~, metadata] = obj.validateMatfile(header);
catch cause
    matfileFailedError(obj, cause, header);
end

% Update the metadata and total members
obj.totalMembers = metadata.members;
obj.metadata_ = metadata;

end

% Error message
function[] = matfileFailedError(obj, cause, header)
id = sprintf('%s:invalidEnsembleFile', header);
ME = MException(id, ['Cannot update %s because the ensemble file is no ',...
    'longer valid. It may have been altered.\n\nFile: %s'], obj.name, obj.file);
ME = addCause(ME, cause);
throwAsCaller(ME);
end
