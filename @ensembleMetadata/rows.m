function[metadata] = rows(obj, dimension, rows, cellOutput)
%% ensembleMetadata.rows  Return the metadata for rows of a state vector ensemble
% ----------
%   metadata = obj.rows(dimension)
%   Return metadata for each row of an ensemble. The first input
%   indicates the dimension for which to return metadata. The dimension
%   must be a state dimension for at least variable in the ensemble.
%
%   The returned metadata will have one row per state vector element (row)
%   in the ensemble. If the metadata for the different variables cannot be
%   concatenated, then returned metadata will be a cell column vector, and
%   each element of the cell vector will hold the metadata for a particular
%   row. If the metadata *can* be concatenated, then the method will
%   concatenate the metadata and return it directly as an array. Typically,
%   metadata values can only be concatenated if they have similar data
%   types and if they have the same sizes along dimensions 2 and 3.
%
%   If a variable is missing the dimension, or does not use the dimension
%   as a state dimension, then the method will use missing values for the
%   rows of the variable. Missing values are NaN for numeric metadata,
%   <missing> for string metadata, ' ' for char, and NaT for datetime. If
%   logical metadata has missing values, the metadata is first converted to
%   "single" and then NaN is used for the missing values. If the metadata
%   for the variables is not compatible and returned as a cell vector, the
%   contents of the cells of the missing elements will be NaN.
%
%   metadata = obj.metadata(0)
%   Returns the name of the variable associated with each state vector
%   element.
%
%   metadata = obj.metadata(dimension, rows)
%   metadata = obj.metadata(dimension, -1)
%   Return metadata at the specified rows of the state vector ensemble. If the
%   second input is -1, selects all rows of ensemble. The returned metadata
%   will have one row per selected state vector row.
%
%   metadata = obj.metadata(dimension, rows, cellOutput)
%   metadata = obj.metadata(dimension, rows, false|"d"|"default")
%   metadata = obj.metadata(dimension, rows, true|"c"|"cell")
%   Specify whether output should always be returned as a cell. If false
%   (default), metadata is returned directly as a matrix when the variables
%   have compatible metadata. If true, metadata is always returned as a
%   cell vector, even when variables have compatiable metadata.
% ----------

% Setup
header = "DASH:ensembleMetadata:rows";
dash.assert.scalarObj(obj, header);
if obj.nVariables==0
    noRowsError;
end

% Check dimension. Require at least 1 variable to use it as a state dimension
if ~isequal(dimension, 0)
    dimension = dash.assert.strflag(dimension, 'dimension', header);
    isState = false;
    for v = 1:obj.nVariables
        if ismember(dimension, obj.stateDimensions{v})
            isState = true;
            break
        end
    end
    if ~isState
        notStateDimensionError;
    end
end

% Default and check rows
nRows = sum(obj.lengths);
if ~exist('rows','var') || isequal(rows, -1)
    rows = 1:nRows;
else
    logicalReq = 'have one element per state vector row';
    linearMax = 'the number of state vector rows';
    rows = dash.assert.indices(rows, nRows, 'rows', logicalReq, linearMax, header);
end
rows = rows(:);

% Default and parse the cell output option
if ~exist('cellOutput','var') || isempty(cellOutput)
    cellOutput = false;
else
    switches = {["d","default"], ["c","cell"]};
    cellOutput = dash.parse.switches(cellOutput, switches, 1, 'cellOutput',...
        'allowed option', header);
end

% Preallocate metadata and missing flags
nRows = numel(rows);
metadata = cell(nRows, 1);
ismissing = false(nRows, 1);

% Identify variables associated with each row. Get unique variables and
% their starting indices
[~, vars] = obj.identify(rows);
uniqueVars = unique(vars);
startRows = obj.find(uniqueVars, 'start');

% Get rows for each variable.
for k = 1:numel(uniqueVars)
    v = uniqueVars(k);
    isvariable = vars==v;
    variableRows = rows(isvariable);

    % Note if the variable is missing the state dimension
    if ~ismember(dimension, obj.stateDimensions{v})
        ismissing(variableRows) = true;

    % Otherwise, get the metadata for the variable
    else
        adjustedRows = variableRows - startRows(k) + 1;
        variableMetadata = obj.variable(v, dimension, 'rows', adjustedRows);

        % Convert metadata array to cell column and collect in output
        [nOnes, nCols, nMean] = size(variableMetadata, 1:3);
        variableMetadata = mat2cell(variableMetadata, ones(nOnes,1), nCols, nMean);
        metadata(isvariable) = variableMetadata;
    end
end

% Attempt to concatenate the non-missing rows
if ~cellOutput
    try
        catMetadata = cat(1, metadata{~ismissing});
        concatenated = true;
    catch
        concatenated = false;
    end
    
    % If unsuccessful, return the cell metadata. If successful and nothing
    % is missing, return the concatenated metadata
    if ~concatenated
        return
    elseif ~any(ismissing)
        metadata = catMetadata;

    % If there are missing values, convert logical to single
    else 
        if islogical(catMetadata)
            catMetadata = single(catMetadata);
        end

        % Preallocate the full metadata. Fill the existing values
        metadata = repmat(catMetadata(1,:,:), [nRows, 1, 1]);
        metadata(~ismissing,:,:) = catMetadata;

        % Fill in the missing values
        fill = missing;
        if ischar(metadata)
            fill = ' ';
        end
        metadata(ismissing,:,:) = fill;
    end
end

end