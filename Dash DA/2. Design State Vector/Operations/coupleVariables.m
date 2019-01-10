function[] = coupleVariables( design, templateVar, coupledVars, varargin )
%% This couples the ensemble indices for specified variables in a state vector design.
%
% coupleVariables( design, templateVar, coupledVars )
% Couples the indices of two variables. Restricts ensemble indices to
% values with equal metadata. Requires ensemble members to use dimension
% values with the 
%
% coupleVariables( design, templateVar, coupledVar, ..., 'includeState' )
% Also couples the indices of state dimensions.
%
% coupleVariables( design, templateVar, coupledVars, ..., 'seq', {seqDex1, seqDex2, ..., seqDexN} )
% Does not couple the sequence indices of variables. Instead, sets them to
% specified values.
%
% coupleVariables( design, templateVar, coupledVars, ..., 'meta', {meta1, meta2, ..., metaN} )
%
% coupleVariables( design, templateVar, coupledVars, ..., 'mean', {meanDex1, meanDex2, ..., meanDexN} ) )
% Does not couple the mean indices of variables. Instead, sets them to
% specified values.
% 
% ----- Inputs -----
% 
% design: A state vector design
%
% templateVar: The name of the variable to which other variables will be
%       coupled. A string.
%
% coupledVars: The names of the variables being coupled to the template
%       variable. Either a single string or a cell vector of strings.
%
% seqDexN: The sequence indices for the Nth coupled variable.
%
% meanDexN: The mean indices for the Nth coupled variable.
%

% Parse the index
[state, seqDex, meanDex] = parseInputs( varargin, {'includeState','seq','mean'}, {false,[],[]}, {'b',[],[]} );

% Error check the inputs
% !!! ?

% Check that the coupled vars do not repeat the template var
if ismember( templateVar, coupledVars )
    error('The coupled variables cannot include the template variable.');
end

% Check that the variables are all in the state vector design
coupledVars{end+1} = templateVar;
if any( ~ismember(coupledVars, design.var) )
    error('All variables must already exist in the state variable design.');
end

% Get the template variable
v = strcmp( templateVar, design.var );
var = design.varDesign(v);

% Get the metadata for the template variable
allMeta = metaGridfile( var.file );

% Preallocate the inputs for a metadata structure
nEns = sum( ~var.isState );
metaArg = cell( nEns*2, 1 );
k = 1;

% For each ensemble dimension, get the possible metadata for ensemble draws
for d = 1:numel(var.dimID)
    if ~var.isState(d)
        metaArg{k} = var.dimID{d};
        metaArg{k+1} = allMeta.( var.dimID{d} )(var.ensDex{d});
        k = k + 2;
    end
end

% Create the metadata structure for the template
tMeta = struct( metaArg{:} );

% Preallocate indices for each variable
nVar = numel( coupledVars );
varSeq = cell( nVar, 1 );
varMean = cell( nVar, 1 );

% For each variable
for v = 1:nVar
    
    % Get the associated metadata


