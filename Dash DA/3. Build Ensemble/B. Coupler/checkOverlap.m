function[ensDim] = checkOverlap( coupVars )

% Get the master set of ensemble dimensions from the first variable. These
% should be identical in all coupled vars.
ensDim = coupVars(1).dimID( ~coupVars(1).isState );

% Get the master set of overlap permissions
overlap = coupVars(1).overlap;

% For each variable
for v = 2:numel(coupVars)
    
    % Get the ensemble dimensions
    currDim = coupVars(v).dimID( ~coupVars(v).isState );
    
    % Check that every ensemble dimension is in the master list and that
    % every dim on the master list is in this variable
    if any(~ismember(ensDim, currDim)) || any(~ismember(currDim,ensDim))
        error('Coupled variables must have the same ensemble dimensions.');
    end

    % Check that overlap is the same
    if ~isequal( overlap, coupVars(v).overlap )
        error('Coupled variables must have the same overlap permissions.';
    end
end

end