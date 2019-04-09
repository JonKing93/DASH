function[coupleSet] = reviewDesign( design )
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
    
    % Check the remaining fields are the correct type and length
    checkVarFields( var );
    
    % Check that the values in the fields are all correct.
    checkVarValues( var );
end

end

