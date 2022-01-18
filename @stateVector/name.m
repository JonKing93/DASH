function[name] = name(obj)
%% stateVector.name  Return an identifying name for a stateVector object
% ----------
%   name = obj.name
%   Returns an identifying name for a stateVector object (typically used for error
%   messages). If the stateVector does not have a label, the name is "the
%   state vector". If the stateVector has a label, the name is of form:
%   state vector "<label>".
% ----------
%   Outputs:
%       name (string scalar): An identifying name for a stateVector object.
%           If the stateVector does not have a label, the name is "the
%           state vector". If the stateVector has a label, the name is of form:
%           state vector "<label>".
%
% <a href="matlab:dash.doc('stateVector.name')">Documentation Page</a>

% Get the label
label = obj.label;

% No label
if strcmp(label, "")
    name = "the state vector";

% Has label
else
    name = sprintf('state vector "%s"', label);
end

end