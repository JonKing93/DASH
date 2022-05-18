function[metadata] = variable(obj, variable, dimension, varargin)
%% ensembleMetadata.variable  Return metadata for a variable in a state vector ensemble
% ----------
%   metadata = obj.variable(v, dimension)
%   metadata = obj.variable(variableName, dimension)
%   Returns the metadata for a particular dimension of a variable. If the
%   dimension is a state dimension, returns the metadata down the rows of
%   the state vector. If the dimension is an ensemble dimension, returns
%   the metadata across the ensemble members. If the dimension is an
%   ensemble dimension with a sequence, returns the sequence metadata down
%   the rows of the state vector.
%
%   metadata = obj.variable(variable, dimension, variableRows)
%   metadata = obj.variable(variable, dimension, members)
%   Return metadata at the specified rows or ensemble members. Here, rows
%   are interpreted relative to the variable's rows, rather than all the
%   rows in the state vector. For example, setting variableRows=1 will return
%   metadata for the first row of the variable, regardless of the
%   variable's overall position in the state vector.
%
%   metadata = obj.variable(..., type)
%   metadata = obj.variable(..., "members"|"m")
%   metadata = obj.variable(..., "rows"|"r")
%   metadata = obj.variable(..., "default"|"d")
%   Specify which type of metadata to return the for the dimension. If
%   "members"|"m", returns metadata across the ensemble members. If
%   "rows"|"r", returns metadata down the rows of the state vector. If
%   "default"|"d", behaves identically to the first syntax and decides
%   internally which metadata to return.
%
%   metadata = obj.variable(variable, dimension, type, rows)
%   metadata = obj.variable(variable, dimension, type, members)
%   Specify both the type of metadata to return, and also the rows or
%   ensemble members.
% ----------
%   Inputs:
%       v (logical vector | scalar linear index): The index of a single
%           variable in the state vector. If a logical vector, must have
%           one element per variable in the state vector and a single true
%           element. Otherwise, use a scalar linear index.
%       variableName (string scalar | char row vector): The name of the variable.
%       dimension (string scalar | char row vector): The name of a
%           dimension for the variable.
%       variableRows (logical vector | vector, linear indices): The rows of the
%           variable at which to return metadata. If a logical vector, must
%           have one element per row in the variable. If a vector of linear
%           indices, elements should be between 1 and the length of the
%           variable.
%       members (logical vector | vector, linear indices): The ensemble
%           members for which to return metadata. If a logical vector, must
%           have one element per ensemble member. Otherwise, a vector of
%           linear indices.
%       type (string scalar): Indicates which type of metadata to return
%           ["d"|"default"]: Let the method decide which type of metadata to return
%           ["r"|"rows"]: Return metadata down the rows of the state vector
%           ["m"|"members"]: Return metadata across the ensemble members
%
%   Outputs:
%       metadata (matrix | 3D array): The metadata for the dimension. If
%           returning metadata for an ensemble dimension, the metadata is a
%           matrix with one row per selected ensemble member. If returning
%           metadata for a sequence or for a state dimension that does not
%           implement a mean, the metadata is a matrix with one row per
%           selected row. If returning metadata for a state dimension that
%           implements a mean, the metadata will be a 3D array. The number
%           of rows will match the number of requested rows, and each row
%           will be identical. The metadata of elements used to implement
%           the mean are organized along the third dimension.
%
% <a href="matlab:dash.doc('ensembleMetadata.variable')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:variable";
dash.assert.scalarObj(obj, header);

% Parse the variable, get the coupling set
v = obj.variableIndices(variable, false, header);
if numel(v)>1
    multipleVariablesError;
end
s = obj.couplingSet(v);

% Parse the remaining inputs
nInputs = numel(varargin);
if nInputs>2
    dash.error.tooManyInputs;
elseif nInputs==2
    type = varargin{1};
    indices = varargin{2};
elseif nInputs==1
    if isnumeric(varargin{1}) || islogical(varargin{1})
        indices = varargin{1};
    elseif dash.is.string(varargin{1})
        type = varargin{1};
    else
        invalidInputError;
    end
end

% Default and parse type
if ~exist('type','var') || isempty(type)
    type = 0;
else
    switches = {["d","default"], ["rows","r"], ["members","m"]};
    type = dash.parse.switches(type, switches, 1, 'type', 'allowedOption', header);
end

% Check the dimension is in the variable and compatible with type
dimension = dash.assert.strflag(dimension, 'dimension', header);
[isState, dState] = ismember(dimension, obj.stateDimensions{v});
[isEnsemble, dEns] = ismember(dimension, obj.ensembleDimensions{s});
if ~isState && ~isEnsemble
    unrecognizedDimension;
elseif type==1 && ~isState
    notStateDimensionError;
elseif type==2 && ~isEnsemble
    notEnsembleDimensionError;
end

% Determine default type
if type==0
    if isState
        type = 1;
    else
        type = 2;
    end
end

% Get the dimension index
if type==1
    d = dState;
else
    d = dEns;
end

% State metadata. Default and error check rows
if type==1
    if ~exist('indices','var')
        rows = 1:obj.lengths(v);
    else
        logicalReq = 'have one element per row of the variable';
        linearMax = 'the number of rows for the variable';
        rows = dash.assert.indices(indices, obj.lengths(v), 'rows', logicalReq, linearMax, header);
    end

    % Get subscripted indices along the dimension
    indices = obj.subscriptRows(v, rows);
    indices = indices{d};

    % Basic metadata or state dimension mean
    metadata = obj.state{v}{d};
    if obj.stateType{v}(d) ~= 1
        metadata = metadata(indices,:);
    else
        metadata = repmat(metadata, numel(indices), 1, 1);
    end

% Ensemble metadata. Default and error check members
else
    if ~exist('indices','var')
        members = 1:obj.nMembers;
    else
        logicalReq = 'have one element per ensemble member';
        linearMax = 'the number of ensemble members';
        members = dash.assert.indices(indices, obj.nMembers, 'members', logicalReq, linearMax, header);
    end

    % Get the metadata
    metadata = obj.ensemble{s}{d}(members, :);
end

end