function[name] = name(obj, capitalize)
%% stateVector.name  Return an identifying name for a stateVector object
% ----------
%   name = <strong>obj.name</strong>
%   Returns an identifying name for a stateVector object (typically used for error
%   messages). If the stateVector does not have a label, the name is "the
%   state vector". If the stateVector has a label, the name is of form:
%   state vector "<label>".
%
%   name = <strong>obj.name</strong>(captalize)
%   Indicate whether to capitalize the first letter of the returned name.
%   Default is to not capitalize (first letter is lowercase).
% ----------
%   Inputs:
%       capitalize (scalar logical): Whether to capitalize the first letter
%           of the returned name (true), or not (false - default).
% 
%   Outputs:
%       name (char row vector): An identifying name for a stateVector object.
%           If the stateVector does not have a label, the name is "the
%           state vector". If the stateVector has a label, the name is of form:
%           state vector "<label>".
%       
%
% <a href="matlab:dash.doc('stateVector.name')">Documentation Page</a>

% Default capitalize
if ~exist('capitalize','var') || isempty(capitalize)
    capitalize = false;
end

% Different names based on label
label = obj.label;
if strcmp(label, "")
    name = 'the state vector';
else
    name = sprintf('state vector "%s"', label);
end

% Optionally capitalize
if capitalize
    name(1) = upper(name(1));
end

end