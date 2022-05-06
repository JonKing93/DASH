function[name] = name(obj)
%% ensemble.name  Returns a name for an ensemble for use in messages
% ----------
%   name = obj.name
%   Returns a name for the ensemble object. If the object has a label,
%   references the label. Otherwise, refers to the object as "the ensemble
%   object".
% ----------

if strcmp(obj.label_, "")
    name = "the ensemble object";
else
    name = sprintf('ensemble "%s"', obj.label_);
end

end