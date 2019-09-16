function[obj] = addVariable( obj, varName, file, autoCouple )
%% Adds a variable to a state vector design.
%
% design = obj.addVariable( varName, file,  )
% Adds a variable to a state vector design.
%
% design = obj.addVariable( varName, file, autoCouple )
% Specify whether to automatically couple the variable to new variables
% added to the state vector. Default is true.
%
% ----- Inputs -----
%
% obj: A state vector design.
%
% varName: The name of the variable. A string scalar or character row
%          vector.
%
% file: The name of the gridfile containing data for the variable. A string
%       scalar or character row vector.
%
% autoCouple: Indicates whether the variable should be automatically
%             coupled to new variables added to the state vector. A logical
%             scalar. Default is true.
%
% ----- Outputs -----
%
% design: The updated state vector design.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Set unspecified fields
if ~exist( 'autoCouple', 'var' )
    autoCouple = true;
end

% Type check the inputs. Convert strings to "string". Prevent duplicate
% variable names
[varName, file] = setup( obj, varName, file, autoCouple );

% Initialize a new varDesign
newVar = varDesign(file, varName);

% Add the variable to the state vector
obj.var = [obj.var; newVar];
obj.varName = [obj.varName; varName];

% Ensure the dimension order is the same for all variables
if ~isequal( newVar.dimID, obj.var(1).dimID )
    error('The order of dimensions in variable %s does not match the order for variable %s.', varName, obj.varName(1) );
end

% Set default coupling and overlap
obj.autoCouple(end+1) = autoCouple;
obj.isCoupled(end+1,end+1) = true;
obj.overlap(end+1) = false;

% If autocoupling, get the other variables and couple
if autoCouple
    v = find( obj.autoCouple )';
    obj = obj.couple( obj.varName(v) );
end

end

% Does type checking on the inputs
function[varName, file] = setup( obj, varName, file, autoCouple )

if ~isstrflag(varName)
    error('varName must be a string.');
elseif ~isstrflag( file )
    error('file must be a string.');
elseif ~islogical(autoCouple) || ~isscalar(autoCouple)
    error('autoCouple must be a scalar logical.');
end

varName = string(varName);
file = string(file);

if ~isempty(obj.varName) && ismember(varName, obj.varName)
    error('Cannot repeat variable names.');
end

end
