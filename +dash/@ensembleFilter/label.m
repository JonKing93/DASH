function[outputs] = label(obj, header, label)
%% dash.ensembleFilter.label  Return or set the label of an filter object
% ----------
%   labelCell = obj.label(header)
%   Returns the label of the current filter.
%
%   objCell = obj.label(header, label)
%   Applies a new label to the filter.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
%       label (string scalar): A new label for the filter
%
%   Outputs:
%       labelCell (scalar cell {label}): The current label of the filter in a cell
%       obj (scalar cell {obj}): The filter with an updated label in a cell
%
% <a href="matlab:dash.doc('dash.ensembleFilter.label')">Documentation Page</a>

% Setup
if ~exist('header','var')
    header = "DASH:ensembleFilter:label";
end
dash.assert.scalarObj(obj, header);

% Return current label
if ~exist('label','var')
    outputs = {obj.label_};

% Apply new label
else
    obj.label_ = dash.assert.strflag(label, 'label', header);
    outputs = {obj};
end

end