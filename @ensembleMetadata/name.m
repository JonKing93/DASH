function[name] = name(obj)
%% ensembleMetadata.name  Return a name for an ensembleMetadata object for use in error messages
% ----------
%   name = obj.name
%   Returns a name for the ensembleMetadata object. If unlabeled, uses: the
%   state vector ensemble. Otherwise, uses: state vector ensemble "label"
% ----------
%   Outputs:
%       name (string scalar): A name for the ensembleMetadata object for
%           use in error messages.
%
% <a href="matlab:dash.doc('ensembleMetadata.name')">Documentation Page</a>

% Base name on label
label = obj.label_;
if strcmp(label, "")
    name = 'the state vector ensemble';
else
    name = sprintf('state vector ensemble "%s"', label);
end

end