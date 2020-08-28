function[] = info(obj)
%% Returns information about a stateVectorVariable
%
% obj.info: Returns information about a state vector variable.
%

% Name
fprintf('\n%s is a state vector variable.\n', obj.name);

% File
fprintf('Data for %s is organized by .grid file "%s"\n', obj.name, obj.file);

% Dimension overview
d = find(obj.gridSize~=1);
nDims = numel(d);
dims = obj.dims(d);
fprintf('%s has %.f non-singleton dimensions: %s\n', obj.name, nDims, dash.errorStringList(dims));

% State dimensions
sd = d(obj.isState(d));
stateDims = obj.dims(sd);
fprintf('\n\tState dimensions: %s\n', dash.errorStringList(stateDims));
for k = 1:numel(stateDims)
    fprintf('\t%s has a length of %.f in the state vector', stateDims(k), obj.size(sd(k)));
        
    % Get string for mean
    meanStr = ' with';
    if obj.hasWeights(sd(k))
        meanStr = sprintf('. It is a weighted mean of %.f', obj.meanSize(sd(k)));
    elseif obj.takeMean(sd(k))
        meanStr = sprintf('. It is a mean of %.f', obj.meanSize(sd(k)));
    end
        
    % Get string for spacing
    spaceStr = '';
    spacing = unique(diff(sort(obj.stateIndices{sd(k)})));
    if numel(spacing)==1
        spaceStr = sprintf('spaced in steps of %.f', spacing);
    end
        
    % Final string
    str = '';
    if numel(spacing)==1 || obj.takeMean(sd(k))
        str = sprintf('%s data elements %s', meanStr, spaceStr);
    end
    fprintf('%s\n', str);
end

end