function[info] = info(obj, variables)
%% stateVector.info  Return information about a state vector
% ----------
%   vectorInfo = <strong>obj.info</strong>
%   vectorInfo = <strong>obj.info</strong>(0)
%   Returns a structure with global information about a state vector.
%
%   variableInfo = <strong>obj.info</strong>(-1)
%   Returns a structure array with detailed information about every
%   variable in the state vector.
%
%   variableInfo = <strong>obj.info</strong>(v)
%   variableInfo = <strong>obj.info</strong>(variableNames)
%   Returns a structure array with information about the specified
%   variables in the state vector.
% ----------
%   Inputs:
%       v (logical vector | vector, linear indices | 0 | -1): The indices of the
%           variables in the state vector for which to return information.
%           If 0, returns global information about the state vector. If -1,
%           returns information about every variable in the state vector.
%       variableNames (string vector): The names of the variables in the 
%           state vector for which to return information.
%
%   Outputs:
%       vectorInfo (scalar struct): Information about the full state vector
%           .label (string scalar): The label of the state vector
%           .length (scalar integer): The number of state vector rows
%           .members (scalar integer): The number of built ensemble members
%               associated with the state vector.
%           .variables (string vector): The names of the variables in the state vector
%           .coupled_variables (cell vector {string vector}): The sets of coupled variables
%           .finalized (scalar logical): Whether the state vector can no longer be edited
%           .serialized (scalar logical): Whether the state vector object is serialized
%       variableInfo (struct vector): Information about variables in the
%           state vector.
%           .name (string scalar): The name of the variable in the state vector
%           .gridfile (string scalar): The absolute path to the .grid file
%               associated with the variable
%           .length (scalar integer): The number of state vector elements
%               for the variable
%           .dimension_names (string vector): The names of the dimensions
%               in the variable
%           .state_dimensions (string vector): The names of the state
%               dimensions for the variable
%           .ensemble_dimensions (string vector): The names of the ensemble
%               dimensions for the variable
%           .dimensions (struct vector): Organizes design parameters for
%               the variable's dimensions. Has one element per dimension.
%               Fields include the following:
%               .name (string scalar): The name of the dimension
%               .length (scalar integer): The number of state vector
%                   elements associated with the dimension
%               .type (string scalar): Whether the dimension is a state or
%                   an ensemble dimension
%               .state_indices (vector, linear indices): The state indices
%                   for the dimension. Empty if an ensemble dimension.
%               .reference_indices (vector, linear indices): The reference
%                   indices for the dimension. Empty if a state dimension.
%               .sequence (scalar struct | []): Sequence design parameters.
%                   Empty if not using a sequence. If using a sequence, a
%                   scalar struct with fields:
%                   .indices (vector, integers): The sequence indices
%                   .metadata (metadata matrix): Sequence metadata
%               .metadata (scalar struct): Metadata options
%                   .type (string scalar): raw, alternate, or convert
%                   .values (metadata matrix): Alternate metadata values.
%                       Only includes this field when using alternate metadata.
%                   .function (scalar function handle): The conversion
%                       function. Only includes this field when using a
%                       conversion function.
%                   .args (cell row vector): Additional arguments for the
%                       conversion function. Only includes this field when
%                       using a conversion function with additional arguments.
%               .mean (scalar struct): Mean design parameters
%                   .type (string scalar): none, standard, or weighted
%                   .nanflag (string scalar): "omitnan" or "includenan".
%                       Only includes this field when taking a mean.
%                   .indices (vector, integers): Mean indices for ensemble
%                       dimensions. Only includes this field when taking a mean
%                       over an ensemble dimension.
%                   .weights (numeric vector): Weights for a weighted mean.
%                       Only includes this field when taking a weighted mean.
%               .total (scalar struct): Sum total parameters
%                   .type (string scalar): none, standard, or weighted
%                   .nanflag (string scalar): "omitnan" or "includenan".
%                       Only includes this field when taking a total.
%                   .indices (vector, integers): Total indices for ensemble
%                       dimensions. Only includes this field when taking a
%                       total over an ensemble dimension
%                   .weights (numeric vector): Weights for a weighted sum.
%                       Only includes this field when taking a weighted total
%           .coupled_variables (string vector): A list of variables that
%               are coupled to the variable
%           .allow_overlap (scalar logical): Whether ensemble members for
%               the variable are permitted to use overlapping information
%           .auto_couple (scalar logical): Whether the variable is
%               automatically coupled to new variables in the state vector.
%
% <a href="matlab:dash.doc('stateVector.info')">Documentation Page</a>

% Setup
header = "DASH:stateVector:info";
dash.assert.scalarObj(obj, header);

% Global information
if ~exist('variables','var') || isequal(variables, 0)
    info = vectorInfo(obj);

% Require unserialized to return variable information
elseif obj.isserialized
    serializedVariableError(obj);

% Parse variables and return info
else
    v = obj.variableIndices(variables, true, header);
    info = variablesInfo(obj, v);
end

end

% Utilities
function[info] = vectorInfo(obj)

info = struct(...
    'label', obj.label_,...
    'length', obj.length,...
    'members', obj.members,...
    'variables', obj.variableNames,...
    'coupled_variables', [],...   % Empty to prevent cell replication
    'finalized', ~obj.iseditable,...
    'serialized', obj.isserialized...
    );
info.coupled_variables = obj.coupledVariables;

end
function[info] = variablesInfo(obj, vars)

% Preallocate
nVars = numel(vars);
info = cell(nVars, 1);

% Get variable internal information
for k = 1:nVars
    v = vars(k);
    info{k} = obj.variables_(v).info;
end
info = cell2mat(info);

% Note original fields
nFields = numel(fieldnames(info));

% Supplement with external info from the vector
for k = 1:numel(vars)
    v = vars(k);
    info(k).name = obj.variableNames(v);
    info(k).gridfile = obj.gridfiles(v);

    coupled = obj.coupled(v,:);
    coupled(v) = false;
    info(k).coupled_variables = obj.variableNames(coupled);
    
    info(k).allow_overlap = obj.allowOverlap(v);
    info(k).auto_couple = obj.autocouple_(v);
end

% Reorder fields
info = orderfields(info, [nFields+(1:2), 1:nFields, nFields+(3:5)]);

end

% Error message
function[] = serializedVariableError(obj)
link ='<a href="matlab:dash.doc(''stateVector.deserialize'')">deserialize</a>';
ME = MException(id, ['%s is serialized, so you cannot use the "info" method ',...
    'to return information about specific variables. You will need to %s ',...
    'the stateVector object first. (Note that you can still use the "info" ',...
    'command to return information about the overall state vector).'], ...
    obj.name(true), link);
throwAsCaller(ME);
end