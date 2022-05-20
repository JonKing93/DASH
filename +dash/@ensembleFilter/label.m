function[varargout] = label(obj, label)
%% ensembleFilter.label  Return or set the label of an ensembleMetadata object
% ----------
%   label = obj.label
%   Returns the label of the current filter.
%
%   obj = obj.label(label)
%   Applies a new label to the filter.
% ----------
%   Inputs:
%       label (string scalar): A new label for the filter
%
%   Outputs:
%       label (string scalar): The current label of the filter
%       obj (scalar ensembleMetadata object): The filter with an updated label.
%
% <a href="matlab:dash.doc('ensembleFilter.label')">Documentation Page</a>

% Setup
header = "DASH:ensembleFilter:label";
dash.assert.scalarObj(obj, header);

% Return current label
if ~exist('label','var')
    varargout = {obj.label_};

% Apply new label
else
    obj.label_ = dash.assert.strflag(label, 'label', header);
    varargout = {obj};
end

end