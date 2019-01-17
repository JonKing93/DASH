function[design] = addVariable( design, file, varargin )
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

% Initialize the varDesign
newVar = varDesign(file, varargin{:});   

% Check that the variable is not a repeat
if ismember(newVar.name, design.varName)
    error('Cannot repeat variable names.');
end        

% Add the variable
design.var = [design.var; newVar];
design.varName = [design.varName; {newVar.name}];

% Adds coupler indices
design.isCoupled(end+1,end+1) = false;
design.coupleState(end+1,end+1) = false;
design.coupleSeq(end+1,end+1) = false;
design.coupleMean(end+1,end+1) = false;

end