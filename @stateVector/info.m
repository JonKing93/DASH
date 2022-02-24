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
%       v (logical vector [nSources] | vector, linear indices): The indices
%           of the variables in the state vector for which to return information.
%       variableNames (string vector): The names of the variables in the 
%           state vector for which to return information.

% Setup
header = "DASH:stateVector:info";
dash.assert.scalarObj(obj, header);
obj.assertUnserialized;

% Parse variables
if ~exist('variables','var') || isequal(variables, 0)
    vars = 0;
elseif isequal(variables, -1)
    vars = 1:obj.nVariables;
else
    vars = obj.variableIndices(variables, true, header);
end
nVars = numel(vars);

% Vector info
if isequal(vars,0)
    error('unfinished');
    return
end

% Get variable information
info = cell(nVars, 1);
for k = 1:nVars
    v = vars(k);
    info{k} = obj.variables_(v).info;
end
info = cell2mat(info);

% Note original fields
nFields = numel(fieldnames(info));

% Supplement variable information
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