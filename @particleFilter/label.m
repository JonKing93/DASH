function[varargout] = label(obj, label)
%% particleFilter.label  Return or set the label of an particleFilter object
% ----------
%   label = <strong>obj.label</strong>
%   Returns the label of the current filter.
%
%   obj = <strong>obj.label</strong>(label)
%   Applies a new label to the filter.
% ----------
%   Inputs:
%       label (string scalar): A new label for the filter
%
%   Outputs:
%       label (string scalar): The current label of the filter
%       obj (scalar particleFilter object): The particle filter with an updated label.
%
% <a href="matlab:dash.doc('particleFilter.label')">Documentation Page</a>

% Header
header = "DASH:particleFilter:label";

% Use cell wrapper for inputs
if ~exist('label','var')
    label = {};
else
    label = {label};
end

% Parse label
varargout = label@dash.ensembleFilter(obj, header, label{:});

end