function[design, v] = markSynced( design, v, field, tf, nowarn )
%% Marks synced indices for variables in a state vector design.
%
% design = markSynced( design, v, field, nowarn )
% 
% ----- Inputs -----
% 
% design: A state vector design.
%
% ----- Outputs -----
%
% v: The full set of synced variables

% Error check
if ~islogical(tf) || ~isscalar(tf)
    error('tf must be a logical scalar.');
end
 
% If syncing
if tf
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
end

% For each variable...
for sv = 1:numel(v)
    
    % Get the other variables
    otherVar = v([1:sv-1, sv+1:numel(v)]);
    
    % Mark as synced
    design.(field)(v(sv), otherVar) = tf;
    design.(field)(otherVar, v(sv)) = tf;
end

end