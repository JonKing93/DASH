function[varargout] = label(obj, label)

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