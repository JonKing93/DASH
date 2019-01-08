function[design] = designVariable( design, var, dim, dimType, index, varargin )
%% A user interface for specifying design parameters for a dimension of a
% variable in a state vector design.
%
% *** Note: This method DOES NOT support logical indexing. Numeric indices
% are required.
%
% STATE DIMENSIONS
% design = designVariable( design, var, dim, 'state', index )
% Specifies indices to use for a dimension in the state vector.
%
% design = designVariable( design, var, dim, 'state', index, 'mean' )
% Uses the mean of the specified indices for a dimension in the state
% vector.
%
% design = designVariable( design, var, dim, 'state', index, 'mean', 'nanflag', flag )
% Specifies how to treat NaN values in a mean. Default is to include NaN
% values.
%
% ENSEMBLE DIMENSIONS
% design = designVariable( design, var, dim, 'ens', index, meta )
% Specifies indices in a dimension from which to draw individual ensemble members.
%
% design = designVariable( design, var, dim, 'ens', index, meta, ..., 'seq', seqDex )
% Select a sequence of elements along a dimension when drawing individual
% ensemble members.
%
% design = designVariable( design, var, dim, 'ens', index, meta, ..., 'mean', meanDex )
% Takes the mean along the specified indices for each member in a sequence.
%
% design = designVariable( design, var, dim, 'ens', index, meta..., 'nanflag', flag)
% Specifies how to treat NaN values in a mean.
%
% ----- Inputs -----
%
% design: A state vector design object containing the variable
%
% var: The variable name. A string.
%
% dim: A dimension ID.

% Check that design and var are allowed
if ~isa( design, 'stateDesign')
    error('Design must be a stateDesign object.');
elseif ~ismember( var, design.var )
    error(['The specified variable is not in the state variable design.', newline, ...
          'Consider using the addStateVariable.m function to initialize it.']);
end

% Get the variable index
[~,v] = ismember(var, design.var);

% For state dimensions
if strcmpi(dimType, 'state')
       
    % Parse the inputs
    [takeMean, nanflag] = parseInputs( varargin, {'mean','nanflag'}, {false, 'includenan'}, {'b',{'omitnan','includenan'}} );
    
    % Add the state dimension design
    design.varDesign(v).stateDim( dim, index, takeMean, nanflag );
    
% For ensemble dimensions
elseif strcmpi(dimType, 'ens')
    
    % Throw error if the meta field is not provided
    if isempty(varargin)
        error('The ''meta'' inputs was not specified.');
        
    % Check that the meta arg was not forgotten
    elseif length(varargin)>1 && ( (~ischar(varargin{2}) && ~isstring(varargin{2})) || ...
            ~ismember(varargin{2},{'mean','seq','nanflag'}) )
        error('String flags are unrecognized or misaligned. The ''meta'' input may be missing.');
    end
    
    % Get the meta arg
    meta = varargin{1};
    varargin(1) = [];
    
    % Parse the inputs
    [seqDex, meanDex, nanflag] = parseInputs( varargin, {'seq','mean','nanflag'}, {0,0,'includenan'}, {[],[],{'includenan','omitnan'}} );
    
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