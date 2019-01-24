function[coupleSet] = reviewCoupling( isCoupled )

% Check for a square matrix
[row,col] = size( isCoupled );
if row~=col
    error('Coupling matrix must be square.');
end

% Set the diagonals to true
isCoupled( 1:row+1:end ) = true;

% Check that the matrix is symmetric
if ~isequal( isCoupled, isCoupled' )
    error('Coupling matrix must be symmetric.');
end

% Initialize the sets of coupled variables.
coupleSet = {};
uncoupled = 1:row;

% Group variables until every variable is in a set.
while ~isempty(uncoupled)
    
    % Get everything coupled with the first uncoupled variable
    coupVars = find( isCoupled( uncoupled(1), :) );
    
    % Check that the coupled variables have identical coupling
    if size( unique( isCoupled(coupVars,:), 'rows' ), 1 ) ~= 1
        error('All variables in a coupling set must be coupled.');
    end
    
    % Add to coupling set
    coupleSet = [coupleSet; coupVars]; %#ok<AGROW>
    
    % Remove from uncoupled variables
    uncoupled( ismember(uncoupled, coupVars) ) = [];
end

end