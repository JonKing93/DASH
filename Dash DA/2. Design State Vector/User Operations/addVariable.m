function[design] = addVariable( design, file, name, couple )
%% Add a variable to a state vector design
%
% design = addVariable( design, file, name )
% Adds a variable to a state vector design.
%
% design = addVariable( design, file, name, couple )
% Specifies whether to couple the variable by default.
%
% ----- Inputs -----
%
% design: A state vector design
%
% file: The name of the gridfile containing data for the variable.
%
% name: A name for the variable
%
% couple: 'couple','nocouple'
%
% ----- Outputs -----
%
% design: The updated state vector design.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Initialize the varDesign
newVar = varDesign(file, name);   

% Check that the variable is not a repeat
if ismember(newVar.name, design.varName)
    error('Cannot repeat variable names.');
end        

% Get the nocouple toggle
if ~exist('couple','var')
    couple = true;
elseif strcmpi(couple, 'nocouple')
    couple = false;
elseif strcmpi(couple,'couple')
    couple = true;
else
    error('Unrecognized ''couple'' input.');
end

% Add the variable
design.var = [design.var; newVar];
design.varName = [design.varName; {newVar.name}];

% Synced indices
design.syncState(end+1,end+1) = false;
design.syncSeq(end+1,end+1) = false;
design.syncMean(end+1,end+1) = false;

% Mark the default coupling choice for the variable
design.defCouple(end+1) = couple;

% Initialize the iscoupled field
design.isCoupled(end+1,end+1) = false;

% If a default coupled variable
if couple
    
    % Get the indices of variables that are coupled by default
    v = find( design.defCouple )';
    
    % If there are other variables, couple
    if numel(v) > 1
        design = coupleVariables( design, design.varName(v(2:end)), design.varName(v(1)), 'nowarn' );
    end
end

end