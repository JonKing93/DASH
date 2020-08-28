function[] = info(obj)
%% Returns information about a stateVectorVariable
%
% obj.info: Returns information about a state vector variable.
%

% Name
fprintf('\n"%s" is a state vector variable.\n', obj.name);

% File
fprintf('Data for %s is organized by .grid file "%s"\n', obj.name, obj.file);

% Dimension overview
d = find(obj.gridSize~=1);
nDims = numel(d);
dims = obj.dims(d);
fprintf('%s has %.f non-singleton dimensions: %s\n', obj.name, nDims, dash.messageList(dims));

% State dimensions
sd = d(obj.isState(d));
stateDims = obj.dims(sd);
fprintf('\n\tSTATE DIMENSIONS: %s\n', dash.messageList(stateDims));
for k = 1:numel(stateDims)
    fprintf('\t%s has a length of %.f in the state vector.\n', stateDims(k), obj.stateSize(sd(k)));
    
    % String for mean
    if obj.stateSize(sd(k))>1 || (obj.takeMean(sd(k)) && obj.meanSize(sd(k))>1)        
        if obj.meanSize(sd(k))==1 || ~obj.takeMean(sd(k))
            meanStr = sprintf('\b');
        elseif obj.hasWeights(sd(k)) 
            meanStr = sprintf('a weighted mean of %.f data elements', obj.meanSize(sd(k)));
        elseif obj.takeMean(sd(k))
            meanStr = sprintf('a mean of %.f data elements', obj.meanSize(sd(k)));
        end
        
        % Get string for spacing
        spaceStr = '';
        spacing = unique(diff(sort(obj.stateIndices{sd(k)})));
        if numel(spacing)==1 && spacing==1
            spaceStr = sprintf('spaced in steps of 1 data index');
        elseif numel(spacing)==1
            spaceStr = sprintf('spaced in steps of %.f data indices', spacing);
        end
        
        % Final string
        if numel(spacing)==1 || (obj.takeMean(sd(k)) && obj.meanSize(sd(k))>1)
            fprintf('\t\tIt is %s %s\n', meanStr, spaceStr);
        end
    end
end

% Ensemble dimensions
sd = d(~obj.isState(d));
ensDims = obj.dims(sd);
fprintf('\n\tENSEMBLE DIMENSIONS: %s\n', dash.messageList(ensDims));
for k = 1:numel(ensDims)
    fprintf('\t%s has %.f elements that can be used in an ensemble.\n', ensDims(k), numel(obj.ensIndices{sd(k)}));
    
    % Sequence information
    if ~isequal(obj.seqIndices{sd(k)}, 0)
        strs = ["a sequence of data elements:", "data indices"];
        if numel(obj.seqIndices{sd(k)}) == 1
            strs(1) = "the data element";
        end
        if isequal( abs(obj.seqIndices{sd(k)}), 1)
            strs(2) = "index";
        end
        list = dash.messageList(obj.seqIndices{sd(k)});
        fprintf('\t\tIt has a length of %.f in the state vector.\n', obj.stateSize(sd(k)));
        fprintf('\t\tIt uses %s %s %s after each reference element.\n', strs(1), list, strs(2));
    end
    
    % Mean information
    if obj.takeMean(sd(k)) && ~isequal(obj.mean_Indices{sd(k)},0)
        type = sprintf('\b');
        if obj.hasWeights(sd(k)) && obj.meanSize(sd(k))>1
            type = 'weighted';
        end
        strs = ["elements", "data indices"];
        if numel(obj.mean_Indices{sd(k)}) == 1
            strs(1) = "element";
        end
        if isequal(abs(obj.mean_Indices{sd(k)}),1)
            strs(2) = "index";
        end
        list = dash.messageList(obj.mean_Indices{sd(k)});
        fprintf('\t\tIt takes a %s mean over the data %s %s %s after each sequence element.\n', type, strs(1), list, strs(2));
    end
end

fprintf('\n');
end