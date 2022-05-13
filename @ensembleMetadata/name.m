function[name] = name(obj)

% Base name on label
label = obj.label_;
if strcmp(label, "")
    name = 'the state vector ensemble';
else
    name = sprintf('state vector ensemble "%s"', label);
end

end