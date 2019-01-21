function[design] = deleteVariable( design, var )
%% Deletes a variable from a state vector design.
%
% design = deleteVariable( design, var )
% Deletes a variable.
%
% ----- Inputs -----
%
% design: A state vector design.
%
% var: The name of the variable being deleted.
%
% ----- Outputs -----
%
% design: The updated state vector design.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the variable index
v = checkDesignVar( design, var );

% Delete
design.var(v) = [];
design.varName(v) = [];

% Delete coupler and sync indices
field = {'isCoupled','syncState','syncSeq','syncMean'};
for f = 1:numel(field)
    design.(field{f})(v,:) = [];
    design.(field{f})(:,v) = [];
end

% Delete default couple and overlap
design.defCouple(v) = [];
design.overlap(v) = [];

end