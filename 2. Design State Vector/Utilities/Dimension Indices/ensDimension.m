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
[index, seq, mean, nanflag, ensMeta, overlap] = parseInputs( varargin, ...
        {'index','seq','mean','nanflag','meta','overlap'}, {[],[],[],[],[],[]}, ...
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
design.var(v).indices{d} = index;
design.var(v).seqDex{d} = seq;
design.var(v).meanDex{d} = mean;
design.var(v).nanflag{d} = nanflag;
design.var(v).takeMean(d) = takeMean;
design.var(v).ensMeta{d} = ensMeta;

end