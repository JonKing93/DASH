function[design] = designVariable( design, var, dim, dimType, index, varargin )
%% This specifies how to use a particular variable in the state vector.
%
%
% design = designVariable( design, var, dim, 'state', index )
% Specifies indices to use for a dimension in the state vector.
%
% design = designVariable( design, var, dim, 'state', index, 'mean' )
% Uses the mean of the specified indices for a dimension in the state
% vector.
%
% design = designVariable( design, var, dim, 'state', index, 'mean', nanflag )
% Specifies how to treat NaN values in a mean. Default is to include NaN
% values.
%
% design = designVariable( design, var, dim, 'ens', index )
% Specifies indices in a dimension from which to draw individual ensemble members.
%
% design = designVariable( design, var, dim, 'ens', index, ..., 'seq', seqDex )
% Select a sequence of elements along a dimension when drawing individual
% ensemble members.
%
% design = designVariable( design, var, dim, 'ens', index, ..., 'mean', meanDex )
% Takes the mean along the specified indices for each member in a sequence.
%
% design = designVariable( design, var, dim, 'ens', index, ..., 'nanflag', flag)
% Specifies how to treat NaN values in a mean.
%
% design = designVariable( design, var, dim, 'ens', ..., 'replace' )
% Indicates to draw random ensemble members with replacement.
%

% Parse the inputs
[takeMean, meanMeta, meanDex, flag, seqDex, replace, nofill] = parseInputs;

% Get the index of the variable in the design
varDex = find( strcmpi( design.var ) );
if isempty(varDex)
    error('The design structure does not contain the specified variable.');
end

% Add to the design
design.varDesign(varDex).specifyDim( dim, takeMean, meanMeta, nanflag, index,...
                                     seqDex, meanDex, replace, nofill);
end