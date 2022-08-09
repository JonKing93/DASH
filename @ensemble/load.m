function[X, metadata] = load(obj, ensembles)
%% ensemble.load  Load the used variables and members of a saved ensemble
% ----------
%   [X, metadata] = <strong>obj.load</strong>
%   Loads a saved ensemble into memory. Only loads the variables and
%   ensemble members being used by the ensemble object. By default, the
%   ensemble object uses all variables and ensemble members saved in the
%   .ens file. Use the "useVariables", "useMembers", and "evolving"
%   commands to instead load a subset of the saved variables and ensemble
%   members.
%
%   If the ensemble object implements a static ensemble, then the first
%   output is a matrix with one row per state vector element, and one
%   column per ensemble member. The second output is a scalar
%   ensembleMetadata object that holds the metadata for this ensemble.
%
%   If the ensemble object implements an evolving ensemble, then the first
%   output is a 3D array. The third dimension holds the different ensembles
%   in the evolving set. The second output is a vector of ensembleMetadata
%   objects, each holding the metadata for a particular ensemble in the
%   evolving set.
%
%   [X, metadata] = <strong>obj.load</strong>(labels)
%   [X, metadata] = <strong>obj.load</strong>(e)
%   [X, metadata] = <strong>obj.load</strong>(-1)
%   Loads specific ensembles in the evolving set. The first output will be a
%   3D matrix and the length of the third dimension will match the number
%   of requested ensembles. The second output will be a vector with one
%   ensembleMetadata object per requested ensemble. If the input is -1,
%   selects all ensembles in the evolving set.
% ----------
%   Inputs:
%       e (-1 | vector, linear indices | logical vector): Indicates the
%           ensembles to load. If -1, loads all ensembles in the evolving
%           set. If a logical vector, must have one element per ensemble in
%           the evolving set. Otherwise, use the linear indices of
%           ensembles in the evolving set.
%       labels (string vector): The labels of specific ensembles in the
%           evolving set. You can only use labels to reference ensembles
%           that have unique labels. Use linear indices to reference 
%           ensembles that share the same label.
%
%   Outputs:
%       X (numeric array, [nState x nMembers x nEvolving]): The loaded
%           ensemble. Each row is a particular element along the state
%           vector, and each column is an ensemble member. The third
%           dimension holds different ensembles in an evolving set. The
%           loaded ensembles will only include variables and ensemble
%           members that are being used by the ensemble object.
%       metadata (ensembleMetadata vector [nEnsembles]): Metadata for the
%           loaded ensemble(s). Each element corresponds to the metadata
%           for the associated ensembles along the third dimension of the
%           first output.
%
% <a href="matlab:dash.doc('ensemble.load')">Documentation Page</a>

% Setup
header = "DASH:ensemble:load";
dash.assert.scalarObj(obj, header);

% Default and check evolving indices
if ~exist('ensembles','var')
    e = 1:obj.nEvolving;
else
    e = obj.evolvingIndices(ensembles, true, header);
end

% Check the .ens file is still valid. Get numeric precision
try
    [m, ~, precision] = obj.validateMatfile(header);
catch cause
    matfileFailedError(obj, cause, header)
end

% Get sizes
nRows = obj.nRows;
nMembers = obj.nMembers;
nEnsembles = numel(e);

% Preallocate
try
    X = NaN([nRows, nMembers*nEnsembles], precision);
catch
    arrayTooLargeError(header)
end

% Get the requested, unique, and strided ensemble members
members = obj.members(e);
[uniqueMembers, ~, whichMember] = unique(members);
nUniqueMembers = numel(uniqueMembers);
stridedMembers = dash.indices.strided(uniqueMembers);
keepMembers = dash.indices.keep(members, stridedMembers);

% Get the variables used by the ensemble. Get their index limits in the
% .ens file and the output array
v = find(obj.use);
nVariables = numel(v);
varFileLimits = dash.indices.limits(obj.lengths);
varFileLimits = varFileLimits(v,:);
varOutputLimits = dash.indices.limits(obj.lengths(v));

% Get blocks of contiguous variables. These variables occupy adjacent
% memory blocks in the .ens file, and can be loaded using strided loading
lastVars = find( diff(v)~=1 )';
blockLimits = [[1;lastVars+1], [lastVars;nVariables]];
nBlocks = size(blockLimits, 1);

% Load each block of contiguous variables. Get the index of the variable
% index at the start and end of each block. (Note that this is an index of
% an index, not the raw variable index itself).
for b = 1:nBlocks
    vStart = blockLimits(b,1);
    vEnd = blockLimits(b,2);

    % Get the rows of each block in the .ens file and output array
    fileRows = varFileLimits(vStart,1) : varFileLimits(vEnd,2);
    outputRows = varOutputLimits(vStart,1) : varOutputLimits(vEnd,2);

    % Attempt to load strided ensemble members all at once
    try
        Xload = m.X(fileRows, stridedMembers);
        loaded = true;
    catch
        loaded = false;
    end

    % If strided loading was successful, keep the requested members
    if loaded
        X(outputRows,:) = Xload(:,keepMembers);

    % Otherwise, load members iteratively
    else
        for m = 1:nUniqueMembers
            fileCols = uniqueMembers(m);
            outputCols = whichMember == m;
            X(outputRows, outputCols) = m.X(fileRows, fileCols);
        end
    end
end

% Reshape loaded array to organize ensembles along the third dimension
X = reshape(X, nRows, nMembers, nEnsembles);

% Optionally get ensembleMetadata output
if nargout>1
    metadata = obj.metadata(e);
end

end

%% Error message
function[] = arrayTooLargeError(nEnsembles, header)

message = ['The ensemble is too large to load into memory. Consider ',...
    'using the "useVariables", "useMembers", and/or "evolving commands to ' ...
    'reduce the size of the loaded array.'];
if nEnsembles>1
    message = sprintf(['%s Altenatively, try loading fewer evolving ensembles ',...
        'than the %.f ensembles currently requested.'], message, nEnsembles);
end
id = sprintf('%s:arrayTooLarge', header);
ME = MException(id, message);
throwAsCaller(ME);

end
function[] = matfileFailedError(obj, cause, header)
id = sprintf('%s:invalidEnsembleFile', header);
ME = MException(id, ['Cannot load data because the ensemble file is no ',...
    'longer valid. It may have been altered.\n\nFile: %s'], obj.file);
ME = addCause(ME, cause);
throwAsCaller(ME);
end