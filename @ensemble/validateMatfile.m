function[m, metadata] = validateMatfile(obj, header)

% Get a matfile object for the ensemble
reset = dash.warning.state('off', 'MATLAB:load:variableNotFound'); %#ok<NASGU> 
try
    m = matfile(obj.file);
catch
    couldNotLoadError(obj, header);
end

% Ensure required fields are present
loadedFields = fieldnames(m);
if ~ismember('X', loadedFields)
    missingDataError(obj, header);
elseif ~ismember('stateVector', loadedFields)
    missingStateVectorError(obj, header);
end

% Check that the data matrix is a non-empty numeric matrix
info = whos(m, 'X', 'stateVector');
type = info(1).class;
siz = info(1).size;

if ~ismember(type, ["single","double"])
    notNumericError(obj, header);
elseif numel(siz) ~= 2
    notMatrixError(obj, header);
elseif any(siz==0)
    emptyEnsembleError(obj, header);
end

% Check that the state vector is a scalar stateVector object
sv = m.stateVector;
if ~isa(sv, 'stateVector')
    notStateVectorError(obj, header);
elseif ~isscalar(sv)
    nonscalarStateVectorError(obj, header)
end

% Check that the state vector sizes match the data matrix
if sv.length ~= siz(1)
    differentRowsError(obj, sv.length, siz(1), header);
elseif sv.members ~= siz(2)
    differentMembersError(obj, sv.members, siz(2), header);

% Check that data sizes match the ensemble object
elseif ~isempty(obj.lengths) && siz(1)~=sum(obj.lengths)
    changedLengthError(obj, obj.length, siz(1), header);
elseif ~isnan(obj.totalMembers) && siz(2)<obj.totalMembers
    tooFewMembersError(obj, obj.totalMembers, siz(2), header);
end

% Build the ensemble metadata object
try
    metadata = ensembleMetadata(sv);
catch
    metadataFailedError(obj, header);
end

% Compare the metadata to current metadata, if it exists
if ~isnan(obj.totalMembers)
    compareMetadata = metadata.extractMembers(1:obj.totalMembers);
    if ~isequaln(obj.metadata_, compareMetadata)
        differentMetadataError(obj, header);
    end
end

end

%% Error messages
function[] = couldNotLoadError(obj, header)
id = sprintf('%s:couldNotLoad', header);
ME = MException(id, ['Could not load data from file:\n\t%s\nIt may not be ',...
    'a valid .ens file.'], obj.file);
throwAsCaller(ME);
end
function[] = missingDataError(obj, header)
id = sprintf('%s:missingDataField', header);
ME = MException(id, ['The ensemble file:\n\t%s\nis missing the data field. ',...
    'It may not be a valid .ens file.'], obj.file);
throwAsCaller(ME);
end
function[] = missingStateVectorError(obj, header)
id = sprintf('%s:missingStateVector', header);
ME = MException(id, ['The ensemble file:\n\t%s\nis missing the stateVector ',...
    'field. It may not be a valid .ens file.'], obj.file);
throwAsCaller(ME);
end
function[] = notNumericError(obj, header)
id = sprintf('%s:ensembleNotNumeric', header);
ME = MException(id, ['The data field in the ensemble file:\n\t%s\nis not numeric. ',...
    'The file may not be a valid .ens file, or may have been altered.'], obj.file);
throwAsCaller(ME);
end
function[] = notMatrixError(obj, header)
id = sprintf('%s:ensembleNotMatrix', header);
ME = MException(id, ['The data field in the ensemble file:\n\t%s\nis not a matrix. ',...
    'The file may not be a valid .ens file or may have been altered.'], obj.file);
throwAsCaller(ME);
end
function[] = emptyEnsembleError
id = sprintf('%s:emptyEnsemble', header);
ME = MException(id, ['The data field in the ensemble file:\n\t%s\nis empty. ',...
    'The file may not be a valid .ens file or may have been altered.'], obj.file);
throwAsCaller(ME);
end
function[] = notStateVectorError(obj, header)
id = sprintf('%s:invalidStateVector', header);
ME = MException(id, ['The stateVector field in the ensemble file:\n\t%s\nis not ',...
    'a stateVector object. The file may not be a valid .ens file or may have been altered.'], obj.file);
throwAsCaller(ME);
end
function[] = nonscalarStateVectorError(obj, header)
id = sprintf('%s:stateVectorNotScalar', header);
ME = MException(id, ['The stateVector field in the ensemble file:\n\t%s\nis not scalar. ',...
    'The file may not be a valid .ens file or may have been altered.'], obj.file);
throwAsCaller(ME);
end
function[] = differentRowsError(obj, nSV, nEns, header)
id = sprintf('%s:differentLengths', header);
ME = MException(id, ['The saved ensemble has %.f state vector elements, but ',...
    'the saved stateVector object has %.f elements. The ensemble file may ',...
    'have been altered.\nFile: %s'], nEns, nSV, obj.file);
throwAsCaller(ME);
end
function[] = differentMembersError(obj, nSV, nEns, header)
id = sprintf('%s:differentMembers', header);
ME = MException(id, ['The saved ensemble has %.f ensemble members, but the ',...
    'saved stateVector object has %.f members. The ensemble file may have ',...
    'been altered.\nFile: %s'], nEns, nSV, obj.file);
throwAsCaller(ME);
end
function[] = changedLengthError(obj, nObj, nSaved, header)
id = sprintf('%s:changedLength', header);
ME = MException(id, ['The saved ensemble has %.f state vector elements (rows), but ',...
    'the ensemble object has %.f. The ensemble file may have been altered ',...
    'after the ensemble object was created.\nFile: %s'], nSaved, nObj, obj.file);
throwAsCaller(ME);
end
function[] = tooFewMembersError(obj, nObj, nSaved, header)
id = sprintf('%s:tooFewMembers', header);
ME = MException(id, ['The number of saved ensemble members (%.f) is smaller ',...
    'than the number of members in the ensemble object (%.f). The ensemble ',...
    'file may have been altered after the ensemble object was created.\nFile: %s'],...
    nSaved, nObj, obj.file);
throwAsCaller(ME);
end
function[] = metadataFailedError(obj, header)
id = sprintf('%s:couldNotBuildMetadata', header);
ME = MException(id, ['Could not buld an ensembleMetadata object from the saved stateVector ',...
    'object. The ensemble file:\n\t%s\nmay not be a valid .ens file, or may ',...
    'have been altered.'], obj.file);
throwAsCaller(ME);
end
function[] = differentMetadataError(obj, header)
id = sprintf('%s:differentMetadata', header);
ME = MException(id, ['The metadata saved in the .ens file does not match the ',...
    'metadata for the ensemble object. The ensemble file may have been altered ',...
    'after the ensemble object was created.\nFile: %s'], obj.file);
throwAsCaller(ME);
end