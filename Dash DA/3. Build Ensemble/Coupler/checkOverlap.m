function[ensDim] = checkOverlap( coupVars )

% Get the master set of ensemble dimensions from the first variable. These
% should be identical in all coupled vars.
ensDim = coupVars(1).dimID( ~coupVars(1).isState );

% Get the master set of overlap permissions
overlap = coupVars(1).overlap( ~coupVars(1).isState );

% For each variable
for v = 2:numel(coupVars)
    
    % Get the ensemble dimensions
    currDim = coupVars(v).dimID( ~coupVars(v).isState );
    
    % Check that every ensemble dimension is in the master list and that
    % every dim on the master list is in this variable
    if any(~ismember(ensDim, currDim)) || any(~ismember(currDim,ensDim))
        error('Coupled variables must have the same ensemble dimensions.');
    end
    
    % Get the permutation index mapping the current dimensions to
    % the master list of ensemble dimensions.
    [~, ensOrder] = ismember( coupVars(v).dimID, ensDim );
    
    % Get the current overlap
    currOver = coupVars(v).overlap;
    
    % Check that the overlap permissions match the master list
    if ~isequal( overlap, currOver(ensOrder) )
        error('Coupled variables must have the same overlap permissions.');
    end
end

end