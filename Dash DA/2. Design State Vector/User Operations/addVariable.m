function[design] = addVariable( design, file, name )
%% Add a variable to a state vector design
%
% design = addVariable( design, file, name )
% Adds a variable with a user-specified name to a state vector design.
%
% design = addVariable( design, file )
% Names the variable after the 'var' field in gridfile metadata.
%
% ----- Inputs -----
%
% design: A state vector design
%
% file: The name of the gridfile containing data for the variable.
%
% name: A name for the variable
%
% ----- Outputs -----
%
% design: The updated state vector design.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% File check, get default name
meta = metaGridfile(file);

 % Get the name if not specified
if ~exist('name','var')
    name = meta.var;
end

% Check that the variable is not a repeat
if ismember(name, design.varName)
    error('Cannot repeat variable names.');
end

% Initialize the varDesign
newVar = varDesign(file, name);           

% Add the variable
design.var = [design.var; newVar];
design.varName = [design.varName; {name}];

% Adds coupler indices
design.isCoupled(end+1,end+1) = false;
design.coupleState(end+1,end+1) = false;
design.coupleSeq(end+1,end+1) = false;
design.coupleMean(end+1,end+1) = false;

end