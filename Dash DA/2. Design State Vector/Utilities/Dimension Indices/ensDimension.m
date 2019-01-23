function[design] = ensDimension( design, var, dim, varargin )
%% Edits an ensemble dimension.

 % Parse inputs
[index, seq, mean, nanflag, ensMeta, overlap] = parseInputs( varargin, ...
        {'index','seq','mean','nanflag','meta','overlap'}, {[],[],[],[],[],[]}, ...
        {[],[],[],{'includenan','omitnan'},[],[]} );
    
% Get the variable index
v = checkDesignVar(design, var);

% Get the dimension index
d = checkVarDim(var,dim);

%% Get the values to use

% Get the indices
if isempty(index)
    index = design.var(v).indices{d};
elseif strcmpi(index,'all')
    index = 1:design.var(v).dimSize(d);
end
checkIndices( design.var(v), d, index );

% Get the value of sequence indices
if isempty(seq)
    seq = design.var(v).seqDex{d};
end
checkIndices(design.var(v), d, seq+1);

% Get the mean indices
if isempty(mean)
    mean = design.var(v).meanDex{d};
end
if ~ismember( 0, mean )
    error('Mean indices must include the 0 index');
end
checkIndices(design.var(v), d, mean+1);


% Takemean
takeMean = true;
if mean == 0
    takeMean = false;
end

% nanflag
if isempty(nanflag)
    nanflag = design.var(v).nanflag{d};
end

% Overlap
if isempty(overlap)
    overlap = design.var(v).overlap;
end
if ~islogical(overlap) || ~isscalar(overlap)
    error('Overlap must be a logical scalar.');
end

% Metadata
if isempty(ensMeta)
    ensMeta = design.var(v).ensMeta{d};
end

%% Sync / Couple

% Get all coupled variables
av = [find(design.isCoupled(v,:)), v];
nVar = numel(av);

% Get any synced variables
sv = [find( design.isSynced(v,:) ), v];

% Notify user if changing from state to ens
if design.var(v).isState(d)
    flipDimWarning( dim, var, {'state','ensemble'}, design.varName(av) );
end

% For each associated variable
for k = 1:nVar
    
    % Get the dimension index
    ad = checkVarDim( design.var(av(k)), dim );
    
    % Change to ensemble dimension. Set coupling
    design.var(av(k)).isState(ad) = false;
    design.var(av(k)).overlap = overlap;
    
    % If a synced variable
    if ismember(av(k), sv)
        
        % Set the indices
        design.var(av(k)).seqDex{ad} = seq;
        design.var(av(k)).meanDex{ad} = mean;
        
        % Set the mean and nanflag, metadata
        design.var(av(k)).nanflag{ad} = nanflag;
        design.var(av(k)).takeMean(ad) = takeMean;
        design.var(av(k)).ensMeta{ad} = ensMeta;
    end
end

% Set the ensemble indices
design.var(v).indices{d} = index;

end