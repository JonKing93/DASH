function[obj] = appendMembers(obj, meta2)
%% Appends a the metadata for the ensemble members of a second state vector
% ensemble to the current ensemble metadata. (across the ensemble)
%
% obj = obj.appendMembers(meta2)
%
% ----- Inputs -----
%
% meta2: A second ensembleMetadata object. Must have exactly the same
%    variables and state vector metadata as the current object.
%
% ----- Outputs -----
%
% obj: The updated ensembleMetadata object

% Error check