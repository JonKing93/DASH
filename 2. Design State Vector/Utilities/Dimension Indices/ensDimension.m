function[design] = ensDimension( design, var, dim, varargin )
%% Edits an ensemble dimension.
%
% See editDesign for use.
%
% ----- Inputs -----
%
% design: the state vector design
%
% var: Variable name
%
% dim: Dimension name
%
% flags: 'index','seq','mean','nanflag','meta','overlap'

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

 % Parse inputs
[index, seq, mean, nanflag, seqMeta, overlap] = parseInputs( varargin, ...
        {'index','seq','mean','nanflag','meta','overlap'}, {[],0,0,[],[],[]}, ...
        {[],[],[],{'includenan','omitnan'},[],[]} );
    
% Get the variable index
v = checkDesignVar(design, var);

% Get the dimension index
d = checkVarDim(design.var(v),dim);

%% Get the values to use

% Get the indices
if isempty(index)
    index = design.var(v).indices{d};
elseif strcmpi(index,'all')
    index = 1:design.var(v).dimSize(d);
elseif islogical(index)
    % Must be a vector length of dimSize
    if ~isvector(index) || numel(index)~=design.var(v).dimSize(d)
        error('Logical indices must be a vector the length of the dimension size.');
    end
    index = find(index(:));
else % Ensure is column
    index = index(:);
end
checkIndices( design.var(v), d, index );

% Error check the mean and sequence indices
checkIndices(design.var(v), d, seq+1);
checkIndices(design.var(v), d, mean+1);

% Ensure seq and mean are column
seq = seq(:);
mean = mean(:);


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

%% Sequence metadata

% Ensure that the metadata is an allowed type
if ~ischar(seqMeta) && ~islogical(seqMeta) && ~isnumeric(seqMeta) && ~iscellstr(seqMeta) && ~isstring(seqMeta)
    error('Sequence metadata must be a numeric, char, string, or cellstring data type.');
elseif isnumeric(seqMeta) && any(isnan(seqMeta))
    error('Sequence metadata may not contain NaN.');
elseif ~ismatrix(seqMeta)
    error('Sequence metadata must be a matrix.');
end

% If metadata as provided, and is a row vector with the number of sequence
% elements, convert to column.
if isrow(seqMeta) && length(seqMeta) == numel(seq)
    seqMeta = seqMeta';
    
% If it was provided, check the number of rows
elseif ~isempty(seqMeta)
    if size(seqMeta,1) ~= numel(seq)
        error('The sequence metadata does not have one row per sequence index.');
    end

% Otherwise, if no metadata is provided...
else
    
    % If there is pre-exisiting metadata, get the previous value
    if ~isempty(design.var(v).seqMeta{d})
        seqMeta = design.var(v).seqMeta{d};
    end
    
    % If the size does not match the number of sequence indices...
    if size(seqMeta,1)~=numel(seq)
        
        % If the sequence length is 1, just use NaN.
        if numel(seq)==1 
            seqMeta = NaN;
            
        % Otherwise throw an error
        else
            error('Sequence metadata for the %s dimension of variable %s was not provided.', dim, var);
        end
    end
end

% Convert char or cellstring metadata to string to allow faster sorting.
if ischar(seqMeta) || iscellstr(seqMeta)                      %#ok<ISCLSTR>
    seqMeta = string(seqMeta);
end

% Ensure that all sequence metadata is unique
if size(seqMeta,1) ~= size( unique(seqMeta,'rows'), 1 )
    error('The sequence metadata contains duplicate values.');
end

%% Coupler

% Get all coupled variables
av = [find(design.isCoupled(v,:)), v];
nVar = numel(av);

% Notify user if changing from state to ens
if design.var(v).isState(d) && numel(av)>1
    flipDimWarning( dim, var, {'state','ensemble'}, design.varName(av(1:end-1)) );
end

% For each associated variable
for k = 1:nVar
    
    % Get the dimension index
    ad = checkVarDim( design.var(av(k)), dim );

    % Change to ensemble dimension. Set coupler
    design.var(av(k)).isState(ad) = false;
    design.var(av(k)).overlap = overlap;
end

% Set the values 
design.var(v).indices{d} = index(:);
design.var(v).seqDex{d} = seq;
design.var(v).meanDex{d} = mean;
design.var(v).nanflag{d} = nanflag;
design.var(v).takeMean(d) = takeMean;
design.var(v).seqMeta{d} = seqMeta;

end