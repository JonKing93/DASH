function[coupVars] = getCoupledVars( design )

% Get the coupling matrix
isCoupled = design.isCoupled;

% Convert the diagonals of isCoupled to true
isCoupled( 1:size(isCoupled,1)+1:end ) = true;

% Initialize a cell to hold indices of coupled variables
coupVars = {};

% Get an index for variables not yet assigned to a set of coupled variables
noset = 1:size(isCoupled,1);

% Get an increment to track the number of sets
k = 1;

% While there are variables remaining
while ~isempty(noset)
    
    % Get the variables coupled to the first variable without a set
    coupVars{k} = find( isCoupled(noset(1),:) ); %#ok<AGROW>
    
    % Get a reference to the first unset variable. (To improve code readability)
    var1 = design.var( noset(1) );
    
    % For each of the coupled variables
    for c = 1:numel(coupVars{k})
        varC = design.var( coupVars{k}(c) );
        
        % Check that they are coupled to exactly the same variables
        if ~isequal( coupVars{k}, find(isCoupled( coupVars{k}(c), : ))  )
            error('Variables %s and %s are coupled, but the other variables to which they are coupled are not the same.', var1.name, varC.name );
        end
        
        % Check that they have the same overlap status
        if var1.overlap ~= varC.overlap
            error('Variables %s and %s are coupled, but they have different overlap permissions.', var1.name, varC.name );
        end
        
        % Check that they have the same ensemble dimensions
        if ~isequal( sort(var1.dimID( ~var1.isState )), sort(varC.dimID( ~varC.isState )) )
            error('Variables %s and %s are coupled, but they do not have the same ensemble dimensions.', var1.name, varC.name );
        end
    end
            
    % Remove from the list of uncoupled variables
    noset( ismember(noset, coupVars{k}) ) = [];
    
    % Increment
    k = k+1;
end

end