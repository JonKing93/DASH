function[coupleSet] = getCoupledVars( design )
%% Gets the sets of coupled variables

% Get the coupling array
isCoupled = design.isCoupled;

% Initialize a cell to hold var indices
coupleSet = {};

% Record an index for all variables
nVar = size(isCoupled,1);
usedVar = NaN( nVar,1 );
k = 0;

% For each variable
for v = 1:nVar
    
    % If there are coupled variables
    if any( isCoupled(v,:) )
        
        % Get the set of coupled variables
        varDex = [v, find(isCoupled(v,:))];
        
        % Assign any coupled variables to the set
        coupleSet = [coupleSet; {varDex}]; %#ok<AGROW>
        
        % Remove vars from the coupling matrix to prevent duplicates
        for vd = 1:numel(varDex)
            isCoupled( varDex(vd), varDex([1:vd-1, vd+1:end])) = false;
            isCoupled(varDex([1:vd-1, vd+1:end]), varDex(vd)) = false;
        end
        
        % Mark the index of the variables
        useDex = k + (1:numel(varDex));
        usedVar(useDex) = varDex;
        k = max(useDex);
    end
end

% Next, get the variables that were not coupled to anything
allVars = (1:nVar)';
uncoupled = allVars( ~ismember(allVars, usedVar) );

% Add to the variable sets
coupleSet = [coupleSet; num2cell(uncoupled)];

end