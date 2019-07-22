function[design] = editDesign( design, var, dim, dimType, varargin )
%% Edits the indices of a dimension for a variable in a state vector design.
%
% STATE DIMENSIONS:
% design = editDesign( design, var, dim, 'state' )
% Sets a dimension as a state dimension and selects all indices. If any
% additional inputs are provided, does not automatically select all indices.
%
% design = editDesign( design, var, dim, 'state', ...., 'index', stateIndex )
% Specifies the state indices.
%
% design = editDesign( design, var, dim, 'state', ..., 'mean', takeMean )
% Specifies whether to take a mean over the state indices.
%
% design = editDesign( design, var, dim, 'state', ..., 'nanflag', nanflag )
% Specifies how to treat NaN values in a mean.
%
% ENSEMBLE DIMENSIONS:
% design = editDesign( design, var, dim, 'ens' )
% Specifies a dimension as an ensemble dimension and selects all indices.
% If additional inputs are provided, does not automatically select all indices.
%
% design = editDesign( design, var, dim, 'ens', ..., 'index', ensIndex )
% Specifies the ensemble indices.
%
% design = editDesign( design, var, dim, 'ens', ..., 'seq', seqIndex, 'meta', seqMeta )
% Specifies the sequence indices and associated metadata to use for an 
% ensemble dimension.
%
% design = editDesign( design, var, dim, 'ens', ..., 'mean', meanIndex )
% Specifies the mean indices to use for an ensemble dimension.
%
% design = editDesign( design, var, dim, 'ens', ..., 'nanflag', flag)
% Specifies how to treat NaN elements in a mean.
%
% design = editDesign( design, var, dim, 'ens', ..., 'overlap', overlap )
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
%
% ensIndex: A list of ensemble indices. May use logical or linear indices.
%       These are the reference indices used for sequences.
%
% seqIndex: A list of sequence indices. These are the number of indices to
%      add to a reference ensemble index to obtain a sequence element.
%
% seqMeta: Metadata associated with each sequence element. Must have one
%          row for each sequence element.
%
% meanIndex: A list of mean indices. These are the indices from each
%       sequence element over which to take a mean.
%
% takeMean: A scalar logical indicating whether to take a mean over a state dimension.
% 
% flag: A string flag specifying how to treat NaN elements in means.
%      'includenan' (Default): Include NaN values.
%      'omitnan': Remove NaN values before taking means.
%
% overlap: A scalar logical indicating whether to allow non-duplicate,
%       overlapping sequences in the ensemble.
%
% ----- Outputs -----
%
% design: The updated state vector design.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% (This is really just an interface so the user doesn't need to remember
% the name of two different fxns. The main utility is to select
% ensDimension of stateDimension).

% Use all indices if no more inputs
if isempty(varargin)
    varargin = {'index','all'};
end

% Check that the dim is a single string
if ischar(dim) && isrow(dim)
    dim = string(dim);
elseif ~isstring(dim) || ~isscalar(dim)
    error('dim must be a single string.')
end

% State dimension
if strcmpi(dimType, 'state')
        
    % Edit state dimension
    design = stateDimension( design, var, dim, varargin{:} );
    
% Ensemble dimension
elseif strcmpi(dimType, 'ens')
    
    % Edit ensemble dimension
    design = ensDimension( design, var, dim, varargin{:} );

% Error
else
    error('The dimension type must be either ''state'' or ''ens''.');
end

end