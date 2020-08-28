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
fprintf('%s has %.f non-singleton dimensions: %s\n', obj.name, nDims, dash.errorStringList(dims));

% State dimensions
sd = d(obj.isState(d));
stateDims = obj.dims(sd);
fprintf('\n\tSTATE DIMENSIONS: %s\n', dash.errorStringList(stateDims));
for k = 1:numel(stateDims)
    fprintf('\t%s has a length of %.f in the state vector.\n', stateDims(k), obj.size(sd(k)));
    
    % String for mean
    if obj.size(sd(k))>1 || (obj.takeMean(sd(k)) && obj.meanSize(sd(k))>1)        
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
fprintf('\n\tENSEMBLE DIMENSIONS: %s\n', dash.errorStringList(ensDims));
for k = 1:numel(ensDims)
    fprintf('\t%s has %.f elements that can be used in an ensemble.\n', ensDims(k), numel(obj.ensIndices{sd(k)}));
    
    % Sequence information
    
    
    
    
    
    
    
end
%     
%     
%     
%     
%     a length of %.f in the state vector.', ensDims(k), obj.size(sd(k)));
%     
%     % String for mean
%     if obj.size(sd(k))>1 || (obj.takeMean(sd(k)) && obj.meanSize(sd(k))>1)        
%         if obj.meanSize(sd(k))==1 || ~obj.takeMean(sd(k))
%             meanStr = sprintf('\b');
%         elseif obj.hasWeights(sd(k)) 
%             meanStr = sprintf('a weighted mean of %.f data elements', obj.meanSize(sd(k)));
%         elseif obj.takeMean(sd(k))
%             meanStr = sprintf('a mean of %.f data elements', obj.meanSize(sd(k)));
%         end
%         
%         % String for spacing
%         spaceStr = '';
%         spacing = unique(diff(sort(obj.stateIndices{sd(k)})));
%         if numel(spacing)==1 && spacing==1
%             spaceStr = sprintf('spaced in steps of 1 data index');
%         elseif numel(spacing)==1
%             spaceStr = sprintf('spaced in steps of %.f data indices', spacing);
%         end
%         
%         % 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
fprintf('\n');
end