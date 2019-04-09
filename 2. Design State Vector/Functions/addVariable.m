function[design] = addVariable( design, file, name, varargin )
%% Add a variable to a state vector design
%
% design = addVariable( design, file, name )
% Adds a variable to a state vector design.
%
% design = addVariable( design, file, name, 'nocouple' )
% Does not couple the variable to other variables by default.
%
% ----- Inputs -----
%
% design: A state vector design
%
% file: The name of the gridfile containing data for the variable.
%
% name: A name for the variable
%
% couple: A flag that specifies whether to couple the variable by default.'couple','nocouple'
%
% ----- Outputs -----
%
% design: The updated state vector design.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the coupling toggle
nocouple = parseInputs(varargin, {'nocouple'}, {false}, {'b'});

% Initialize the varDesign
newVar = varDesign(file, name);   

% Check that the variable is not a repeat
if ~isempty(design.varName) && ismember(newVar.name, design.varName)
    error('Cannot repeat variable names.');
end        

% Add the variable
design.var = [design.var; newVar];
design.varName = [design.varName; newVar.name];

% Mark the default coupling choice for the variable
design.defCouple(end+1) = ~nocouple;

% Initialize the iscoupled field
design.isCoupled(end+1,end+1) = false;

% If a default coupled variable
if ~nocouple
    
    % Get the indices of variables that are coupled by default
    v = find( design.defCouple )';
    
    % If there are other variables, couple
    if numel(v) > 1
        design = coupleVariables( design, design.varName(v(2:end)), design.varName(v(1)), 'nowarn' );
    end
end

end