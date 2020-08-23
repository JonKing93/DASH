function[obj] = edit( obj, varName, dim, dimType, varargin ) 
%% Edits the design specifications of a variable in the state vector.
%
% BASIC USAGE:
%
% design = obj.edit( varName, dim, dimType, ... flags/values )
% Edits a variable in the state design. Edits a particular dimension, and
% specifies whether the dimension is a state or ensemble dimension. Various
% flags and additional arguments further modify the design.
%
% By default, all dimensions are set to state dimensions, and all indices
% are enabled. Optional arguments are detailed below.
%
%
% STATE DIMENSIONS:  obj.edit( varName, dim, 'state', ... )
%
% obj.edit( ..., 'index', stateIndex )
% Specifies state indices for the dimension.
%
% obj.edit( ..., 'mean', takeMean )
% Specify whether to take a mean over the dimension.
%
%
% ENSEMBLE DIMENSIONS:  obj.edit( varName, dim, 'ens', ... )
%
% obj.edit( ..., 'index', ensIndex )
% Specifies ensemble indices for the dimension.
%
% obj.edit( ..., 'mean', meanIndex )
% Specifies sequential indices over which to take a mean.
%
% obj.edit( ..., 'seq', seqIndex, 'meta', seqMeta )
% Specifies sequence indices and associated metadata for the dimension.
%
% obj.edit( ..., 'overlap', allowOverlap )
% Specify whether the variable (and associated coupled variables) permit
% overlapping, non-duplicate sequences. By default, overlap is prohibited.
%
% 
% EITHER:
%
% obj.edit( ..., 'mean', true/meanIndex, 'nanflag', nanflag )
% Specify how to treat NaN elements when taking a mean.
%
%
% ----- Inputs -----
%
% obj: A state vector design
%
% varName: The name of the variable to edit
%
% dim: The name of the dimension to edit
%
% dimType: The type of dimension.
%       'state': A state dimension.
%       'ens':   An ensemble dimension.
%
%
% State dimension arguments:
%
%    stateIndex: A list of state indices. Either linear indices, or a
%                logical vector the length of the dimension.
%
%    takeMean: A scalar logical indicating whether to take a mean over a
%              state dimension.
%
%
% Ensemble dimension arguments:
%
%    ensIndex: A list of ensemble indices. Either linear indices, or a
%              logical vector the length of the dimension.
%
%    meanIndex: A list of mean indices. Either linear indices, or a
%              logical vector the length of the dimension.
%
%    seqIndex: A list of sequence indices. Either linear indices, or a
%              logical vector the length of the dimension.
%
%    seqMeta: Metadata associated with each sequence element. Either a
%             matrix with one row per sequence element, or a vector with
%             one element per sequence element.
%
%    allowOverlap: A scalar logical indicating whether overlap is permitted
%                  for the variable and associated coupled variables.
%
%
% Either dimension arguments:
%
%    nanflag: A flag indicating how to treat NaN elements in a mean.
%           'includenan' (Default): Include NaN values.
%           'omitnan': Remove NaN values before taking means.%
%
% ----- Outputs -----
%
% design: The updated state vector design.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% (This is really just an interface so the user doesn't need to remember
% the name of two different fxns. The main purpose is to provide a central
% location for the "help" information, and to feed inputs into
% stateDimension or ensDimension, which do the actual work.)

% Error check
if ~isstrflag(varName)
    error('varName must be a string scalar.');
elseif ~isstrflag(dim)
    error('dim must be a string scalar.');
elseif ~isstrflag(dimType)
    error('dimType must be a string scalar.');
elseif ~ismember( dimType, ["state","ens"] )
    error('dimType must either be "state" or "ens".');
end

% Variable and dimenion on which to operate
v = obj.findVarIndices( varName );
d = obj.findDimIndices( v, dim );

% Edit a state or ensemble dimension
if strcmpi( dimType, "state" )
    obj = obj.stateDimension( v, d, varargin{:} );
else
    obj = obj.ensDimension( v, d, varargin{:} );
end

end