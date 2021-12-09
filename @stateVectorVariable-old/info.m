function[varInfo, dimInfo] = info(obj)
%% Returns information about a stateVectorVariable
%
% obj.info
% Prints information about the state vector variable to the console.
%
% [varInfo, dimInfo] = obj.info
% Returns summary variable information as a structure, and dimension info
% as a structure array. Does not print to console.
%
% ----- Outputs -----
%
% varInfo: A structure containing information on the state vector variable
%
% dimInfo: A structure containing information on the dimensions of the
%    state vector variable

% Variable summary
name = obj.name;
file = obj.file;
stateSize = prod(obj.stateSize);
obj = obj.trim;
ensSize = prod(obj.ensSize);
singleDims = obj.dims(obj.gridSize==1);
dims = obj.dims(obj.gridSize~=1);
stateDims = obj.dims(obj.isState & obj.gridSize>1);
ensDims = obj.dims(~obj.isState & obj.gridSize>1);

% Output structure
if nargout~=0
    input = cell(1, numel(obj.infoFields)*2);
    input(1:2:end) = obj.infoFields;
    input(2:2:end) = {name, file, stateSize, ensSize, dims, stateDims, ensDims, singleDims};
    varInfo = struct( input{:} );
    
    % Preallocate dimension structure
    nDims = numel(dims);
    dimFields = {'name','type','stateLength','ensembleMembers','indices',...
        'sequence','hasMean','meanIndices','weights'};
    [dimInfo, dimInputs] = dash.struct.preallocate(dimFields, [nDims, 1]);

% Print to console
else
    fprintf('"%s" is a state vector variable.\n', obj.name);
    fprintf('Data for %s is organized by .grid file "%s"\n', obj.name, obj.file);
    statePlural = "s";
    if stateSize == 1
        statePlural = "";
    end
    ensPlural = ["are", "s"];
    if ensSize==1
        ensPlural = ["is",""];
    end
    fprintf('The state vector for %s is %.f element%s long. There %s %.f possible ensemble member%s.\n', ...
        name, stateSize, statePlural, ensPlural(1), ensSize, ensPlural(2));
end

% Cycle through state dimensions first
sd = find(obj.isState & obj.gridSize>1);
ed = find(~obj.isState & obj.gridSize>1);
alldims = [sd, ed];

% Dimension info
for k = 1:numel(alldims)
    d = alldims(k);
    name = obj.dims(d);
    indices = obj.indices{d};
    hasMean = obj.takeMean(d);
    weights = NaN;
    if obj.hasWeights(d)
        weights = obj.weightCell{d};
    end

    % State specific
    if obj.isState(d)
        type = "state";
        stateSize = obj.stateSize(d);
        ensSize = NaN;
        sequence = NaN;
        meanIndices = NaN;
        
    % Ensemble specific
    else
        type = "ensemble";
        stateSize = obj.stateSize(d);
        ensSize = obj.ensSize(d);
        sequence = obj.seqIndices{d};
        meanIndices = obj.mean_Indices{d};
    end
 
    % Output structure
    if nargout>0
        dimInputs(2:2:end) = {name, type, stateSize, ensSize, indices, sequence, ...
                          hasMean, meanIndices, weights};
        dimInfo(k) = struct(dimInputs{:});

    % Print to console
    else
        % State dimension header
        if strcmp(type,'state')
            if d==sd(1)
                fprintf('\n\tSTATE DIMENSIONS: %s\n', dash.string.messageList(stateDims));
            end
            fprintf('\t%s has a length of %.f in the state vector.\n', name, stateSize);

            
            % String for mean
            if stateSize>1 || (hasMean && obj.meanSize(d)>1)
                if obj.meanSize(d)==1 || ~hasMean
                    meanStr = sprintf('\b');
                elseif obj.hasWeights(d) 
                    meanStr = sprintf('a weighted mean of %.f data elements', obj.meanSize(d));
                elseif hasMean
                    meanStr = sprintf('a mean of %.f data elements', obj.meanSize(d));
                end
                
                % String for spacing
                spaceStr = '';
                spacing = unique(diff(sort(indices)));
                if numel(spacing)==1 && spacing==1
                    spaceStr = sprintf('spaced in steps of 1 data index');
                elseif numel(spacing)==1
                    spaceStr = sprintf('spaced in steps of %.f data indices', spacing);
                end
                
                % Final string
                if numel(spacing)==1 || (hasMean && obj.meanSize(d)>1)
                    fprintf('\t\tIt is %s %s\n', meanStr, spaceStr);
                end
            end
        
        % Ensemble dimension header
        else
            if d==ed(1)
                fprintf('\n\tENSEMBLE DIMENSIONS: %s\n', dash.string.messageList(ensDims));
            end
            fprintf('\t%s has %.f elements that can be used in an ensemble.\n', name, numel(indices));
            
            % Sequence information
            if ~isequal(sequence, 0)
                strs = ["a sequence of data elements:", "data indices"];
                if numel(sequence)==1
                    strs(1) = "the data element";
                end
                if isequal(abs(sequence), 1)
                    strs(2) = "index";
                end
                list = dash.string.messageList(sequence);
                fprintf('\t\tIt has a length of %.f in the state vector.\n', stateSize);
                fprintf('\t\tIt uses %s %s %s after each reference element.\n', strs(1), list, strs(2));
            end
        
            % Mean information
            if hasMean && ~isequal(meanIndices,0)
                weighted = sprintf('\b');
                if obj.hasWeights(d) && obj.meanSize(d)>1
                    weighted = 'weighted';
                end
                strs = ["elements", "data indices"];
                if numel(meanIndices)==1
                    strs(1) = "element";
                end
                if isequal(abs(meanIndices),1)
                    strs(2) = "index";
                end
                list = dash.string.messageList(meanIndices);
                fprintf('\t\tIt takes a %s mean over the data %s %s %s after each sequence element.\n', weighted, strs(1), list, strs(2));
            end
        end
    end
end

end