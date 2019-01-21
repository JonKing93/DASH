function[design] = editDesign( design, var, dim, dimType, index, varargin )
%% Edits the indices of a dimension for a variable in a state vector design.
%
%
% STATE DIMENSIONS:
% design = editDesign( design, var, dim, 'state', stateIndex )
% Specifies a state indices.
%
% design = editDesign( design, var, dim, 'state', stateIndex, 'mean')
% Specifies state indices over which to take a mean.
%
% design = editDesign( design, var, dim, 'state', stateIndex, 'mean', 'nanflag', flag)
% Specifies state indices over which to take a mean. Specifies how to treat
% NaN values in the mean.
%
% ENSEMBLE DIMENSIONS:
% design = editDesign( design, var, dim, 'ens' )
% Specifies a dimension as an ensemble dimension with all indices enabled.
%
% design = editDesign( design, var, dim, 'ens', ensIndex )
% Specifies ensemble indices.
%
% design = editDesign( design, var, dim, 'ens', ensIndex, ..., 'seq', seqIndex )
% Specifies the sequence indices to use for an ensemble dimension.
%
% design = editDesign( design, var, dim, 'ens', ensIndex, ..., 'mean', 'meanIndex' )
% Specifies the mean indices to use for an ensemble dimension.
%
% design = editDesign( design, var, dim, 'ens', ensIndex, ..., 'nanflag', flag)
% Specifies how to treat NaN elements in a mean.
%
% design = editDesign( design, var, dim, 'ens', ensIndex, ..., 'overlap', overlap )
% Specifies whether the variable (and coupled variables) permit or prohibit
% overlapping, non-duplicate sequences in the ensemble. By default,
% overlapping sequences are prohibited. 
%
% ----- Inputs -----
%
% design: A state vector design
%
% var: The name of the variable to edit
%
% dim: The name of the dimension to edit
%
% stateIndex: A list of state indices. May use logical or linear indices.
%      If the string 'all', then all indices in the dimension are selected.
%      If NaN or [], does not alter the current indices.
%
% ensIndex: A list of ensemble indices. May use logical or linear indices.
%      If the string 'all', then all indices in the dimension are selected. 
%
% seqIndex: A list of sequence indices. These are the number of indices to
%      add to a reference ensemble index to obtain a sequence member.
%
% meanIndex: A list of mean indices. These are the number of indices to add
%      add to a reference sequence element to use in taking a mean. Must
%      include the 0 index.
%
% flag: A string flag specifying how to treat NaN elements in means.
%      'includenan' (Default): Include NaN values.
%      'omitnan': Remove NaN values before taking means.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Use all indices if unspecified
if ~exist('index','var')
    index = 'all';
end

% State dimension
if strcmpi(dimType, 'state')
    
    % Parse inputs
    [takeMean, nanflag] = parseInputs( varargin, {'mean','nanflag'},{false,'includenan'},{'b',{'omitnan','includenan'}} );
    
    % Edit state dimension
    design = stateDimension( design, var, dim, index, takeMean, nanflag );
    
% Ensemble dimension
elseif strcmpi(dimType, 'ens')
    
    % Parse inputs
    [seq, mean, nanflag, ensMeta, overlap] = parseInputs( varargin, {'seq','mean','nanflag','meta'}, ...
                                 {0,0,'includenan',NaN}, {{},{},{'omitnan','includenan'},{}} );
    
    % Edit ensemble dimension
    design = ensDimension( design, var, dim, index, seq, mean, nanflag, ensMeta );

% Error
else
    error('Unrecognized dimension type.');
end

end