function[name] = name(obj)
%% ensemble.name  Returns a name for an ensemble for use in messages
% ----------
%   name = <strong>obj.name</strong>
%   Returns a name for the ensemble object. If the object has a label,
%   references the label. Otherwise, refers to the object as "the ensemble
%   object".
% ----------
%   Outputs:
%       name (string scalar): A name for the object for use in error
%           messages.
%
% <a href="matlab:dash.doc('ensemble.name')">Documentation Page</a>

if strcmp(obj.label_, "")
    name = "the ensemble object";
else
    name = sprintf('ensemble "%s"', obj.label_);
end

end