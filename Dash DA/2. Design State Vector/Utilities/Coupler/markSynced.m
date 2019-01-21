function[design] = markSynced( design, v, field, nowarn )
%% Marks synced indices for variables in a state vector design.
%
% design = markSynced( design, v, field, nowarn )
% 
% ----- Inputs -----
% 
% design: A state vector design.
%
% xv: The index of the template variable in the design
%
% yv: The index of the synced variables in the design.
%
% syncState / syncSeq / syncMean: Logical for whether the indices are synced.

% Get all previously synced variables
prevSync = design.(field)(v,:);
[~,prevSync] = ind2sub( size(design.(field)), find(prevSync) );

% Get previously synced variables not in the current list
nv = prevSync( ~ismember(prevSync,v) );

% Notify user that these variables will also be synced
if ~nowarn && ~isempty(nv)
    prevSyncWarning( design.varName(nv), field );
end

% Get the full set of synced variables
v = unique([v;nv]);

% For each synced variable...
for sv = 1:numel(v)
    
    % Get the other variables
    otherVar = [1:sv-1, sv+1:numel(v)];
    
    % Mark as synced
    design.(field)(sv, otherVar) = true;
    design.(field)(otherVar, sv) = true;
end

end