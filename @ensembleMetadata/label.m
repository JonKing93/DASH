function[varargout] = label(obj, label)
%% ensembleMetadata.label  Return or set the label of an ensembleMetadata object
% ----------
%   label = obj.label
%   Returns the label of the current ensembleMetadata object.
%
%   obj = obj.label(label)
%   Applies a new label to the ensembleMetadata object.
% ----------
%   Inputs:
%       label (string scalar): A new label for the ensembleMetadata object
%
%   Outputs:
%       label (string scalar): The current label of the ensembleMetadata object
%       obj (scalar ensembleMetadata object): The ensembleMetadata object
%           with an updated label.
%
% <a href="matlab:dash.doc('ensembleMetadata.label')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:label";
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