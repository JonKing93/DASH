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
design.overlap(end+1) = false;

% Initialize the iscoupled field
design.isCoupled(end+1,end+1) = false;

% If a default coupled variable
if couple
    
    % Get the indices of variables that are coupled by default
    v = find( design.defCouple )';
    
    % If there are other coupled variables
    if numel(v)>1
    
        % Mark the variables as coupled
        design = markSynced(design, v, 'isCoupled', true);
    
        % Get one of the variables as a template for coupling ensemble
        % indices.
        X = design.var(v(1));
        
        % Get the ensemble dimensions
        ensDim = find( ~X.isState );
    
        % For each ensemble dimension
        for d = 1:numel(ensDim)
            % Notify user of coupling.
            if d == 1
                fprintf('Coupling variable %s: \n', design.varName{end});
            end
            
            % Get the index in the new variable
            dim = checkVarDim( design.var(end), X.dimID{ensDim(d)} );
            
            % Flip the isState toggle in the new variable
            design.var(end).isState(dim) = false;
            
            % Notify user
            fprintf('\tConverting %s to an ensemble dimension.\n', X.dimID{ensDim(d)} );
        end
    end
end

end