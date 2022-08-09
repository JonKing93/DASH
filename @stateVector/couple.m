function[obj] = couple(obj, variables, template)
%% stateVector.couple  Couple variables in a state vector
% ----------
%   obj = <strong>obj.couple</strong>
%   obj = <strong>obj.couple</strong>(-1)
%   Couples all the variables in the state vector to one another. Coupled
%   variables are required to have matching metadata within ensemble
%   members of a state vector ensemble. This ensures that, within an
%   ensemble member, the data from different variables all align to the same
%   point. By default, all variables in a state vector are automatically
%   coupled to one another, so this method is only necessary if you have
%   previously disabled autocoupling.
%
%   When the ensemble dimensions of a variable are changed, the ensemble
%   dimensions of coupled variables will be updated to match. Note that
%   this update does not copy reference/state indices across variables.
%   Only the status of a dimension as an ensemble/state dimension is
%   updated. For this syntax, the first variable in the state vector is used
%   as a template variable; the ensemble dimensions and autocoupling
%   settings of all other variables will be updated to match those of the
%   template.
%
%   obj = <strong>obj.couple</strong>(v)
%   obj = <strong>obj.couple</strong>(variableNames)
%   Couples the listed variables to one another. Coupling is transitive,
%   so any unlisted variables that are already coupled to the listed variables will
%   also be coupled. The first listed variable is used as the template
%   variable; the ensemble dimensions and autocoupling settings of all
%   variables being coupled will be updated to match this template.
%
%   obj = <strong>obj.couple</strong>(variables, t)
%   obj = <strong>obj.couple</strong>(variables, templateName)
%   Specify the variable to use as a template. All listed variables, as
%   well as unlisted variables already coupled to the listed variables,
%   will be coupled to this template. The ensemble dimensions and
%   autocoupling settings of all variables being coupled will be updated to
%   match this template.
% ----------
%   Inputs:
%       v (logical vector | linear indices | -1): The indices of variables in
%           the state vector that should be coupled. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. If -1, selects all variables in the state
%           vector.
%       variableNames (string vector): The names of variables in the state
%           vector that should be coupled.
%       t (logical vector | linear index): The index of a variable that
%           should be used as the coupling template.
%       templateName (string scalar): The name of a variable that should be
%           used as the coupling template.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector with updated
%           coupled variables.
%
% <a href="matlab:dash.doc('stateVector.couple')">Documentation Page</a>

% Setup
header = "DASH:stateVector:couple";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Check user variables, get indices
if ~exist('variables','var')
    variables = -1;
elseif isempty(variables)
    variables = [];
end
v = obj.variableIndices(variables, true, header);

% Error check template variable
if ~exist('template','var') || isempty(template)
    t = [];
else
    t = obj.variableIndices(template, true, header);
    t = unique(t);
    if numel(t)>1
        tooManyTemplatesError(obj, t, header);
    end
end

% Organize the variable indices and template. Exit if there are <2 variables
if isempty(v)
    return
elseif isempty(t)
    t = v(1);
else
    v = [t; v(:)];
end
v = unique(v);
if numel(v)==1
    return
end

% Get the full set of coupling variables
[~, col] = find(obj.coupled(v,:));
v = unique(col);

% Update coupled variables to match the coupling template
[obj, failed, cause] = obj.coupleDimensions(t, v, header);
if failed
    couplingFailedError(obj, t, failed, cause, header);
end
obj.autocouple_(v) = obj.autocouple_(t);

% Record coupling status
obj.coupled(v,v) = true;

end

% Error message
function[] = tooManyTemplatesError(obj, t, header)

id = sprintf('%s:tooManyTemplates', header);
ME = MException(id, ['You can only specify a single variable as a coupling ',...
    'template, but you have specified %.f templates for %s.'], numel(t), obj.name);
throwAsCaller(ME);

end
function[] = couplingFailedError(obj, t, vFailed, cause, header)

tName = obj.variables(t);
vName = obj.variables(vFailed);

vector = '';
if ~strcmp(obj.label, "")
    vector = sprintf('in %s ', obj.name);
end

id = sprintf('%s:couldNotCoupleVariable', header);
ME = MException(id, ['Could not couple the "%s" variable to the "%s" variable %s',...
    'because the dimensions of "%s" could not be updated to match "%s".'],...
    vName, tName, vector, vName, tName);

ME = addCause(ME, cause);
throwAsCaller(ME);

end