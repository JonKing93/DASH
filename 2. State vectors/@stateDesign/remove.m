function[obj] = remove(obj, varNames)
%% Deletes variables from a state vector design.
%
% design = obj.remove( varNames )
% Deletes a set of variables from a state vector.
%
% ----- Inputs -----
%
% obj: A state vector design.
%
% varNames: A list of variable names. Either a character row, cellstring,
%           or string vector.
%
% ----- Outputs -----
%
% design: The updated state vector design.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

if ~isempty( varNames )
    % Get the variable indices
    v = obj.findVarIndices( varNames );

    % Delete from design fields
    obj.var(v) = [];
    obj.varName(v) = [];
    obj.isCoupled(v,:) = [];
    obj.isCoupled(:,v) = [];
    obj.autoCouple(v) = [];
    obj.allowOverlap(v) = [];
end

end