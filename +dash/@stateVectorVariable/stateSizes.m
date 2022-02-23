function[sizes, types] = stateSizes(obj)
%% dash.stateVectorVariable.stateSizes  Returns the sizes and names of state dimensions

% Get non-trivial state dimensions
d = find(obj.isState | obj.hasSequence);

% Empty case
if isempty(d)
    sizes = [];
    types = strings(1,0);
    return
end

% Sizes and dims
sizes = obj.stateSize(d);

% Types (dimension + comment)
if nargout>1
    types = strings(size(d));
    types(obj.hasSequence(d)) = " sequence";
    types(obj.isState(d) & obj.meanType(d)~=0) = " mean";
    types = strcat(obj.dims(d), types);
end

end