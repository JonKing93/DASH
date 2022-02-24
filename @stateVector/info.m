function[info] = info(obj, variables)
%% stateVector.info  Return information about a state vector
% ----------
%   vectorInfo = <strong>obj.info</strong>
%   vectorInfo = <strong>obj.info</strong>(0)
%   Returns a structure with information about a state vector.
%
%   variableInfo = <strong>obj.info(-1)</strong>
%   Returns a structure array with detailed information about all of the
%   variables in the state vector.
%
%   variableInfo = <strong>obj.info</strong>(v)
%   variableInfo = <strong>obj.info</strong>(variableNames)
%   Returns a structure array with information about the specified
%   variables in the state vector.
% ----------
%   Inputs:
%       v (logical vector | vector, linear indices): The indices of the
%           variables in the state vector for which to return information.
%       variableNames (string vector): The names of the variables in the 
%           state vector for which to return information.

% Setup
header = "DASH:stateVector:info";
dash.assert.scalarObj(obj, header);

% Parse variables, require unserialized if returning variable information
if ~exist('variables','var') || isequal(variables, 0)
    v = 0;
elseif obj.isserialized
    serializedVariableError(obj);
elseif isequal(variables, -1)
    v = 1:obj.nVariables;
else
    v = obj.variableIndices(variables, true, header);
end

% Information about the entire vector or certain variables
if isequal(v, 0)
    info = vectorInfo(obj);
else
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