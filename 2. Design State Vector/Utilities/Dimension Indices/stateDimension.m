function[design] = stateDimension( design, var, dim, varargin )
%% Edits a state dimension.
%
% See editDesign for use.
%
% ----- Inputs ----- 
% design: state vector design
%
% var: Variable name
%
% dim: Dimension name
%
% flags: 'index','mean','nanflag'

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Parse the inputs
[index, takeMean, nanflag] = parseInputs( varargin, {'index','mean','nanflag'}, {[],[],[]}, {[],[],{'omitnan','includenan'}} );

% Get the variable index
v = checkDesignVar( design, var );

% Get the dimension index
d = checkVarDim( design.var(v), dim );

%% Get the values to use

% Get the indices to use
if isempty(index)
    index = design.var(v).indices{d};
elseif strcmpi(index, 'all')
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
checkIndices( design.var(v), d, index);

% Get the value of takeMean
if isempty(takeMean)
    takeMean = design.var(v).takeMean(d);
end
if ~islogical(takeMean) || ~isscalar(takeMean)
    error('takeMean must be a logical scalar.');
end

% Get the nanflag
if isempty(nanflag)
    nanflag = design.var(v).nanflag{d};
end


%% Coupled variables

% Get all coupled variables
av = [find(design.isCoupled(v,:)), v];
nVar = numel(av);

% Notify user if changing from ens to state dimension
if ~design.var(v).isState(d) && numel(av)>1
    flipDimWarning(dim, var, {'ensemble','state'}, design.varName(av(1:end-1)));
end

% For each associated variable
for k = 1:nVar
    
    % Get the dimension index for the associated variable
    ad = checkVarDim( design.var(av(k)), dim );
    
    % Change dimension to state dimension
    design.var(av(k)).isState(ad) = true;
end

% Set the values
design.var(v).indices{d} = index;
design.var(v).takeMean(d) = takeMean;
design.var(v).nanflag{d} = nanflag;

% Return ensemble dimension properties to empty.
design.var(v).seqDex{d} = [];
design.var(v).meanDex{d} = [];
design.var(v).ensMeta{d} = [];

end