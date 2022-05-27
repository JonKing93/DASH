function[varargout] = prior(obj, X, whichPrior)
%% kalmanFilter.prior  Set or return the prior for a Kalman filter
% ----------
%   obj = obj.prior(X)
%   Provide the prior for a Kalman filter direclty as a numeric array. 
%   Overwrites any previously specified prior. Each row is a state vector
%   element, and each column is an ensemble member. Each element along the
%   third dimension holds a particular prior in an evolving set. If using a
%   static prior, X should have a single element along the third dimension. 
%   Otherwise, X should have one element along the third dimension per 
%   assimilation time step. In this case, the Kalman filter will use the
%   indicated prior for each assimilated time step.
%
%   obj = obj.prior(ens)
%   Provide the prior using ensemble objects. To implement a static prior,
%   the input should be a scalar ensemble object that implements a static
%   prior. 
% 
%   For evolving priors, the input may either be:
%   1. A scalar ensemble object that implements an evolving ensemble, or
%   2. A vector of ensemble objects that all implement static ensembles.
%   In the first case, the number of priors for the assimilation will match
%   the number of ensembles in the evolving set. In the second case, the
%   number of priors for the assimilation will match the number of elements
%   in the vector of ensemble objects. The number of evolving priors must
%   match the number of assimilation time steps (although see the syntax
%   below for relaxing that requirement). If using a vector of ensemble
%   objects, all the objects must implement ensembles with the same number
%   of state vector elements (nRows) and ensemble members (nMembers).
%
%   obj = obj.prior(  X, whichPrior)
%   obj = obj.prior(ens, whichPrior)
%   Indicate which prior to use in each assimilation time step. This syntax
%   allows the number of priors to differ from the number of time steps.
%
%   [  X, whichPrior] = obj.prior
%   [ens, whichPrior] = obj.prior
%   Returns the current prior for the Kalman filter object, and indicates
%   which prior is used in each assimilation time step.
%
%   obj = obj.prior('delete')
%   Deletes the current prior(s) from the Kalman filter object.
% ----------
%   Inputs:
%       X (numeric matrix [nState x nMembers x 1|nTime|nPrior]): The
%           prior(s) for the Kalman filter. A numeric array with one row
%           per state vector element, and one column per ensemble member.
%           Each element along the third dimension holds a unique prior. If
%           using a static prior, X should have one element along the third
%           dimension. If the number of priors matches the number of time
%           steps, uses the appropriate prior for each time step. If the
%           number of priors is neither 1 nor the number of time steps, use
%           the whichPrior input to indicate which prior to use in each
%           assimilation time step. If the prior for a state vector element
%           includes NaN values in a particular time step, then the updated
%           state vector element will be NaN in that time step.
%       ens (scalar ensemble object <static | evolving [nPrior]> | 
%            vector, <static> ensemble objects [nPrior]):
%           The prior for the Kalman filter, provided via ensemble
%           objects. For a static prior, a scalar ensemble object that
%           implements a static ensemble. For an evolving ensemble, either
%           a scalar ensemble object that implements an evolving ensemble,
%           OR a vector of ensemble objects that implement static
%           ensembles. If providing a vector of ensemble objects, each
%           object must implement an ensemble with the same number of state
%           vector elements (rows) and ensemble members (columns). If the
%           number of priors matches the number of time steps, uses the
%           appropriate prior for each time step. If the number of priors
%           is neither 1 nor the number of time steps, use the whichPrior
%           input to indicate which prior to use in each assimilation time
%           step. If the prior for a state vector element includes NaN
%           values in a particular time step, then the updated state vector
%           element will be NaN in that time step.
%       whichPrior (vector, positive integers [nTime]): Indicates which
%           prior to use in each assimilation time step. Must have one element
%           per assimilation time step.
%
%   Outputs:
%       obj (scalar kalmanFilter object): The kalmanFilter object with the
%           udpated prior.
%       X (numeric matrix [nState x nMembers x 1|nTime|nPrior]): The current
%           prior for the kalmanFilter object. If you have not provided a
%           prior, returns an empty array.
%       ens (scalar ensemble object <static | evolving [nPrior]> | 
%            vector, <static> ensemble objects [nPrior]):
%           The current prior for the kalmanFilter object. If you have not
%           provided a prior, returns an empty array.
%       whichPrior (vector, positive integers [nTime] | []): Indicates which
%           prior is used in each assimilation time step. If there is a static
%           prior, returns an empty array.
%
% <a href="matlab:dash.doc('kalmanFilter.prior')">Documentation Page</a>

% Header
header = "DASH:kalmanFilter:prior";

% Use a cell wrapper for inputs
if ~exist('X', 'var')
    inputs = {};
elseif ~exist('whichPrior','var')
    inputs = {X};
else
    inputs = {X, whichPrior};
end

% Parse the prior
[varargout, type] = prior@dash.ensembleFilter(obj, header, inputs{:});
varargout = obj.validateSizes(varargout, type, 'prior(s)', header);

% If deleting or setting, extract the updated object and locate posterior indices
if strcmp(type,'delete') || strcmp(type, 'set')
    obj = varargout{1};
    indices = find(obj.calculationTypes==2);

    % If deleting, remove all posterior indices
    if strcmp(type, 'delete')
        if any(indices)
            obj.calculations(indices,:) = [];
            obj.calculationNames(indices,:) = [];
            obj.calculationTypes(indices,:) = [];
    
            % Notify user of deleted indices
            names = obj.calculationNames(indices);
            userNames = eraseBetween(names, 1, strlength(obj.indexHeader));
            id = sprintf('%s:deletingPosteriorIndices', header);
            warning(id, ['Deleting posterior indices because they require a prior.\n',...
                'Deleted indices: %s'], dash.string.list(userNames));
        end
    
    % If setting, locate indices that require a specific number of rows
    elseif strcmp(type, 'set')
        if any(indices)
            
            % Get maximum row for each index
            nIndex = numel(indices);
            maxRow = NaN(nIndex, 1);
            for k = 1:nIndex
                c = indices(k);
                maxRow(k) = max(obj.calculations{c}.rows);
            end

            % Throw error if a maximum row exceed nState
            if any(maxRow > obj.nState)
                tooFewRowsError(obj, indices, maxRow, header);
            end
        end
    end
end

end

%% Error messages
function[] = tooFewRowsError(obj, indices, maxRow, header)
bad = find(maxRow > obj.nState, 1);
k = indices(bad);
name = obj.calculationNames(k);
name = eraseBetween(name, 1, strlength(obj.indexHeader));
id = sprintf('%s:tooFewRows', header);
ME = MException(id, ['The "%s" index uses data from state vector row %.f ',...
    'but the new prior only has %.f state vector rows. Either delete the "%s" index ',...
    'or increase the number of rows.'], name, maxRow(bad), obj.nState, name);
throwAsCaller(ME);
end