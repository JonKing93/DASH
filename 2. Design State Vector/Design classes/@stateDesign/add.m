function[obj] = add( obj, varName, file, autoCouple )
%% Adds a variable to a state vector design.
%
% design = addVariable( varName, file,  )
% Adds a variable to a state vector design.
%
% design = addVariable( varName, file, autoCouple )
% Specify whether to automatically couple the variable to new variables
% added to the state vector. Default is true.
%
% ----- Inputs -----
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

% Set autoCouple if not specified
if ~exist( 'autoCouple', 'var' )
    autoCouple = true;
end

% Type check the inputs. Convert strings to "string"
[varName, file] = setup( varName, file, autoCouple );
    
% Check that the variable name is not a repeat
if ~isempty(obj.varName) && ismember(varName, obj.varName)
    error('Cannot repeat variable names.');
end

% Initialize a new varDesign
newVar = varDesign(file, name);

% Add the variable to the state vector
obj.var(end+1) = newVar;
obj.varName(end+1) = varName;

% Mark the default coupling choice for the variable
obj.autoCouple(end+1) = autoCouple;

% Initialize the iscoupled field
obj.isCoupled(end+1,end+1) = false;

% Autocouple if specified
if autoCouple
    
    % Get the autocoupled variables
    v = find( obj.autoCouple )';
    
    % Couple them.
    obj = obj.couple( obj.varName(v);
end

end

% Does type checking on the inputs
function[varName, file] = setup( varName, file, autoCouple )

if ~isstrflag(varName)
    error('varName must be a string.');
elseif ~isstrflag( file )
    error('file must be a string.');
elseif ~islogical(autoCouple) || ~isscalar(autoCouple)
    error('autoCouple must be a scalar logical.');
end

varName = string(varName);
file = string(file);

end
