function[] = reviewDesign( design )
%% Error checks a state vector design.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Ensure that the design is a state design
if ~isa(design, 'stateDesign')
    error('design must be a stateDesign object.');
end

% Check that the coupling matrix is a symmetric logical matrix
if ~islogical(design.isCoupled) || ~ismatrix(design.isCoupled) || ~issymmetric(design.isCoupled)
    error('The "isCoupled" field of the stateDesign must be a symmetric logical matrix.');
end

% Get the number of variables
nVar = numel(design.var);

% For each variable
for v = 1:nVar
    var = design.var(v);
    
    % Ensure the variable is a named varDesign
    if ~isa( var, 'varDesign')
        error('Variable %.f of the stateDesign is not a varDesign object.', v);
    elseif ~isstrflag(var.name)
        error('The name of variable %.f is not a string.', v);
    end
    
    % Error check the file, dimID, dimSize, and meta fields by checking that
    % the values for the variable match the values in the .grid file.
    checkVarMatchesGrid( var );
    
    % Record the dimension IDs from the first variable, and check that each
    % variable has only these dimensions
    if v == 1
        dimID = var.dimID;
    elseif numel(var.dimID)~=numel(dimID) || any( ~ismember(var.dimID, dimID) )
        error('Variables %s and %s do not have the same dimension IDs.', var.name, design.var(1).name );
    end
    
    % Check the remaining fields are the correct type and length
    checkVarFields( var );
    
    % Check that the values in the fields are all correct.
    checkVarValues( var );
end

% Check that coupled variables have the same overlap permission
coupVars = getCoupledVars( design );
for cv = 1:numel(coupVars)
    vars = design.var( coupVars{cv} );
    
    for v = 2:numel(vars)
        if vars(1).overlap ~= vars(v).overlap
            error('Coupled variables %s and %s do not have the same overlap permission.', vars(1).name, vars(v).name);
        end
    end
end

end

