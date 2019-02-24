function[design, v] = markCoupled( design, v, nowarn )
%% Marks the couple or sync relationship between variables in a state design.
%
% [design, allvar] = markSynced( design, v, nowarn )
% 
% ----- Inputs -----
% 
% design: A state vector design.
%
% v: The variables
%
% nowarn: A logical indicating whether to warn for secondary realtionships
%
% ----- Outputs -----
%
% design: The edited design
%
% allvar: The full set of specified and secondary variables.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check
if ~islogical(nowarn) || ~isscalar(nowarn)
    error('nowarn must be a logical scalar.');
end
    
% Get all variables with a positive relationship with the variables
prevRelate = find( design.isCoupled(v,:) );
[~,prevRelate] = ind2sub( size(design.isCoupled(v,:)), prevRelate );
prevRelate = unique(prevRelate,'stable');

% Get secondary variables. (Those with a relationship not in the specified list)
sv = prevRelate( ~ismember(prevRelate,v) );

% Warn that these will also be altered
if ~nowarn && ~isempty(sv)
    prevSyncWarning( design.varName(v), design.varName(sv)  );
end

% Get the full set of related variables
v = [v;sv];
nVar = numel(v);

% For each variable
for k = 1:nVar
    
    % Get the other variables
    otherVar = v([1:k-1, k+1:nVar]);
    
    % Mark the relationship
    design.isCoupled(v(k), otherVar) = true;
    design.isCoupled(otherVar, v(k)) = true;
end
    
end