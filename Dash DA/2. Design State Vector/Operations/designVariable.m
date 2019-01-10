function[design] = designVariable( design, var, dim, dimType, index, varargin )
%% A user interface for specifying design parameters for a dimension of a
% variable in a state vector design.
%
% *** Note: This method DOES NOT support logical indexing. Numeric indices
% are required.
%
% STATE DIMENSIONS
% design = designVariable( design, var, dim, 'state', stateDex )
% Specifies indices to use for a dimension in the state vector.
%
% design = designVariable( design, var, dim, 'state', stateDex, 'mean' )
% Uses the mean of the specified indices for a dimension in the state
% vector.
%
% design = designVariable( design, var, dim, 'state', stateDex, 'mean', 'nanflag', flag )
% Specifies how to treat NaN values in a mean. Default is to include NaN
% values.
%
% ENSEMBLE DIMENSIONS
% design = designVariable( design, var, dim, 'ens', ensDex )
% Specifies indices in a dimension from which to draw individual ensemble members.
%
% design = designVariable( design, var, dim, 'ens', 'all' )
% Uses all indices in the dimension to draw individual ensemble members.
%
% design = designVariable( design, var, dim, 'ens', ensDex, meta, ..., 'seq', seqDex )
% Select a sequence of elements along a dimension when drawing individual
% ensemble members.
%
% design = designVariable( design, var, dim, 'ens', ensDex, ..., 'meta', meta)
% Specifies a metadata value to use for each sequence member. Providing
% metadata is HIGHLY RECOMMENDED and a warning is issued if no metadata is
% provided.
%
% design = designVariable( design, var, dim, 'ens', ensDex, ..., 'noWarn' )
% Disables the metadata warning for batch processing.
%
% design = designVariable( design, var, dim, 'ens', ensDex, meta, ..., 'mean', meanDex )
% Takes the mean along the specified indices for each member in a sequence.
%
% design = designVariable( design, var, dim, 'ens', ensDex, meta..., 'nanflag', flag)
% Specifies how to treat NaN values in a mean.
%
% ----- Inputs -----
%
% design: A state vector design object that contains the variable.
%
% var: The variable name. A string.
%
% dim: A dimension ID.
%
% stateDex: The indices of the dimension to use in every state vector.
%
% ensDex: The indices of the dimension to use for selecting ensemble
%   members. The values in ensDex should only include the starting index of
%   sequences. If ensDex is the string 'all' or the string ':', then all
%   indices of the dimension will be used to draw ensemble members.
%
% flag: A string flag specifying how to treat NaN in means.
%   'includenan' (Default): Includes NaN values in means.
%   'omitnan': Does not include NaN values in means.
%
% meta: A cell containing the metadata value for each sequence member of an
%       ensemble dimension. {nSeq x 1}
%
% seqDex: Indicates the indices of sequence members relative to the first
%       member of a sequence. Must contain the zero index.
%
% meanDex: Indicates the indices over which to take a mean for sequence
%       members relative to the starting index of each sequence. Must
%       contain the 0 index.
%
% ----- Outputs -----
%
% design: The updated state vector design.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check that design and var are allowed
v = checkDesignVars(design, var);

% For state dimensions
if strcmpi(dimType, 'state')
       
    % Parse the inputs
    [takeMean, nanflag] = parseInputs( varargin, {'mean','nanflag'}, {false, 'includenan'}, {'b',{'omitnan','includenan'}} );
    
    % Get any variables with coupled state indices
    coupled = find( design.coupleState );
    
    % Make sure that the indices are allowed in all coupled variables
    checkCoupledStateIndex( design.varDesign(v), design.varDesign(coupled), index )
    
    
    
    
    % Check if the state indices are permitted for coupled variables.
    checkStateCoupling();
    
    %
    
    
    
    
    
    
    
    
    
    
    
    
    % Add the state dimension design
    design.varDesign(v).stateDim( dim, index, takeMean, nanflag );
    
% For ensemble dimensions
elseif strcmpi(dimType, 'ens')
    
    % Parse the inputs
    [seqDex, meanDex, nanflag, meta, nowarn] = parseInputs( varargin, {'seq','mean','nanflag','meta','nowarn'}, {0,0,'includenan',[],false}, {[],[],{'includenan','omitnan'},[],'b'} );
    
    % Warn if no metadata
    if ~nowarn && isempty(meta)
        warning('No metadata was provided the ensemble dimension. Metadata is highly recommended.');
    end
    
    % Set metadata to NaN if unspecified
    if isempty(meta)
        meta = NaN( size(seqDex) );
    end    
    
    % Note if taking a mean
    takeMean = false;
    if ~isequal(takeMean, 0)
        takeMean = true;
    end
    
    % Add an ensemble dimension
    design.varDesign(v).ensembleDim( dim, meta, index, seqDex, meanDex, takeMean, nanflag );
    
% Error for unrecognized.
else
    error('Unrecognized dimension type.');
end

end