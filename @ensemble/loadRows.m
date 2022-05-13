function[X] = loadRows(obj, rows, ensembles)
%% ensemble.loadRows  Load specific rows of the used subset of a saved ensemble
% ----------
%   X = obj.loadRows(rows)
%   Loads specific rows of the ensemble into memory. The rows are
%   determined relative to the subset of the saved ensemble that is being
%   used by the ensemble object. Only the elements of variables being used
%   by the ensemble are counted as state vector rows. By default, the
%   ensemble object uses all variables saved in the .ens file. Use the
%   "useVariables" command to instead load a subset of the saved variables.
%
%   If the ensemble object implements a static ensemble, then the output
%   array is a matrix with one row per requested row, and one column per
%   used ensemble member. If the object implements an evolving ensemble,
%   then the output array is a 3D array, and the third dimension holds the
%   requested rows for different ensembles in the evolving set.
% 
%   X = obj.loadRows(rows, labels)
%   X = obj.loadRows(rows, e)
%   X = obj.loadRows(rows, -1)
%   Load rows for specific ensembles in the evolving set. The output array
%   will be a 3D matrix and the length of the third dimension will match
%   the number of requested ensembles. If the second input is -1, selects
%   all ensembles in the evolving set.
% ----------

% Setup
header = "DASH:ensemble:loadRows";
dash.assert.scalarObj(obj, header);

% Check the rows
logicalReq = 'have one element per state vector element';
linearMax = 'the number of state vector elements';
rows = dash.assert.indices(rows, obj.nRows, 'rows', logicalReq, linearMax, header);

% Default and check evolving indices
if ~exist('ensembles','var')
    e = 1:obj.nEvolving;
else
    e = obj.evolvingIndices(ensembles, true, header);
end

% Check the .ens file is still valid. Get numeric precision
m = obj.validateMatfile(header);
info = whos(m, 'X');
precision = info.class;

% Get sizes
nRows = numel(rows);
nMembers = obj.nMembers;
nEnsembles = obj.nEvolving;

% Preallocate
try
    nCols = nMembers * nEnsembles;
    X = NaN([nRows, nCols], precision);
catch
    arrayTooLargeError;
end

% Get strided ensemble members
members = obj.members(e);
stridedMembers = dash.indices.strided(members);
keepMembers = dash.indices.keep(members, stridedMembers);

% Get the file variable associated with each row
usedLimits = dash.indices.limits(obj.length(-1));
if ~isrow(rows)
    rows = rows';
end
inVariable = rows>=usedLimits(:,1) & rows<=usedLimits(:,2);
[vRows, ~] = find(inVariable);
vUsed = find(obj.use);
vRows = vUsed(vRows);
rows = rows';

% Locate requested rows in the .ens file
notCounted = obj.lengths;
notCounted(obj.use) = 0;
nMissing = [0; cumsum(notCounted(1:end-1))];
rows = rows + nMissing(vRows,1);

% Attempt to load strided rows
stridedRows = dash.indices.strided(rows);
try
    Xload = m.X(stridedRows, stridedMembers);
    loaded = true;
catch
    loaded = false;
end

% If loaded, build the output array and exit
if loaded
    keepRows = dash.indices.keep(rows, stridedRows);
    X(:,:) = Xload(keepRows, keepMembers);
    return
end

% If strided loading didn't work, attempt to load strided rows for
% individual variables. Record which variables are loaded
limits = dash.indices.limits(obj.lengths);
vars = unique(vRows);
nVars = numel(vars);

% Locate requested rows associated with each variable
for k = 1:nVars
    v = vars(k);
    inVariable = rows>=limits(v,1) & rows<=limits(v,2);
    variableRows = rows(inVariable);

    % Attempt to load strided rows within the variable
    stridedRows = dash.indices.strided(variableRows);
    try
        Xload = m.X(stridedRows, stridedMembers);
        loaded = true;
    catch
        loaded = false;
    end

    % If successful, add to the output array and move to the next variable
    if loaded
        keepRows = dash.indices.keep(variableRows, stridedRows);
        X(inVariable,:) = Xload(keepRows, keepMembers);
        continue
    end

    % If unsuccessful, get unique rows for the variable
    uniqueRows = unique(variableRows);
    keepRows = dash.indices.keep(variableRows, uniqueRows);
    nVarRows = numel(uniqueRows);
    Xvar = NaN([nVarRows, nCols], precision);

    % Load each row iteratively
    for r = 1:nVarRows
        try
            Xload = m.X(uniqueRows(r), stridedMembers);
            loaded = true;
        catch
            loaded = false;
        end

        % If successful, extract the requested members
        if loaded
            Xvar(r,:) = Xload(1, keepMembers);

        % If still unsuccessful, also load each member iteratively
        else
            for c = 1:nCols
                Xvar(r,c) = m.X(uniqueRows(r), members(c));
            end
        end
    end

    % Add the rows for the variable to the output array
    X(inVariable,:) = Xvar(keepRows, :);
end

% Reshape output array to organize ensembles along the third dimension
X = reshape(X, nRows, nMembers, nEnsembles);

end