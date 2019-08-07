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