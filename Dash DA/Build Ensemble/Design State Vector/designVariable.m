function[design] = designVariable( design, var, dim, dimType, index, varargin )
%% This specifies how to use a particular variable in the state vector.
%
%
% design = designVariable( design, var, dim, 'state', index )
% Specifies indices to use for a dimension in the state vector.
%
% design = designVariable( design, var, dim, 'state', index, 'mean', meanMeta )
% Uses the mean of the specified indices for a dimension in the state
% vector. Specifies the metadata value to use for the mean.
%
% design = designVariable( design, var, dim, 'state', index, ..., 'nanflag', flag )
% Specifies how to treat NaN values in a mean. Default is to include NaN
% values.
%
% design = designVariable( design, var, dim, 'ens', index )
% Specifies indices to use for a dimension when drawing individual ensemble
% members.
%
% design = designVariable( design, var, dim, 'ens', index, ..., 'seq', seqDex )
% Select a sequence of elements along a dimension when drawing individual
% ensemble members.
%
% design = designVariable( design, var, dim, 'ens', index, ..., 'mean',
% meanMeta, meanDex )
% Takes the mean along the specified indices for each member in a sequence.
%
% design = designVariable( design, var, dim, 'ens', index, ..., 'nanflag',
% flag)
% Specifies how to treat NaN values in a mean.
%
% design = designVariable( design, var, dim, 'ens', ..., 'replace' )
% Indicates to draw random ensemble members with replacement.
%
% design = designVariable( design, var, dim, 'ens', ..., 'noFill', 'any' )
% Does not select state vectors in which any element along the dimension is
% NaN.
%
% design = designVariable( design, var, dim, 'ens', ..., 'noFill', 'all' )
% Does not select state vectors in which all the elements along the
% dimension are NaN.

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