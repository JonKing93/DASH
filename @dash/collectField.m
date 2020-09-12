function[values] = collectField(s, field)
%% Collects the values in a field of a structure vector.
%
% values = dash.collectField(s, field)
%
% ----- Inputs -----
%
% s: The structure vector
%
% field: The name of the field. A string scalar or character row vector.
%
% ----- Outputs -----
%
% values: The values in the field. A cell vector with one element per
%    structure in s.

nEls = numel(s);
values = cell(nEls, 1);
[values{:}] = deal(s.(field));

end