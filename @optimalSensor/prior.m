function[varargout] = prior(obj, X)
%% optimalSensor.prior  Set or return the prior for an optimal sensor
% ----------
%   obj = obj.prior(X)
%   obj = obj.prior(ens)
%   Provide the prior for an optimal sensor object. Overwrites any
%   previously specified prior. If the prior has exactly 1 state vector
%   row, uses the prior directly as the initial sensor metric unless
%   otherwise specified. The prior may either be a numeric matrix or a
%   scalar ensemble object. If a numeric matrix, each row is a state vector
%   element, and each column is an ensemble member. If using an ensemble
%   object, the ensemble must implement a static ensemble.
%
%   X = obj.prior
%   ens = obj.prior
%   Returns the current prior for the particle filter object.
%
%   obj = obj.prior('delete')
%   Deletes the current prior from the particle filter object. Also deletes
%   any specified options for determining a metric from the prior.
% ----------
%   Inputs:
%       X (numeric matrix [nState x nMembers): The prior for the optimal
%           sensor. A numeric matrix with one row per state vector element
%           and one column per ensemble member.
%       ens (scalar ensemble object <static>): The prior for the optimal
%           sensor as a static ensemble object
%
%   Outputs:
%       obj (scalar particleFilter object): The particleFilter object with the
%           udpated prior.
%       X (numeric matrix [nState x nMembers]): The current prior for the
%           optimalSensor object. If you have not provided a prior, returns
%           an empty array.
%       ens (scalar ensemble object <static>): The current prior for the
%           optimalSensor object when using an ensemble object.
%
% <a href="matlab:dash.doc('optimalSensor.prior')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:prior";
dash.assert.scalarObj(obj, header);

% Return estimates
if ~exist('X','var')
    varargout = {obj.X};

% Delete prior
elseif dash.is.string(X) && strcmpi(X, 'delete')
    obj.X = [];
    obj.Xtype = NaN;

    % Reset sizes
    obj.nState = 0;
    if isempty(obj.Ye)
        obj.nMembers = 0;
    end

    % Reset metrics and return output
    obj.metricType = NaN;
    obj.metricArgs = {};
    varargout = {obj};

% If setting, don't allow an empty prior
else
    if isempty(X)
        emptyPriorError(obj, header);
    end

    % If estimates are set, require matching number of members
    siz = NaN(1,2);
    if ~isempty(obj.Ye)
        siz(2) = obj.nMembers;
    end

    % Numeric array. Require well-defined matrix. Get sizes
    if isnumeric(X)
        Xtype = 0;
        dash.assert.matrixTypeSize(X, ["single","double"], siz, 'X', header);
        dash.assert.defined(X, 2, 'X', header);
        [nState, nMembers] = size(X, 1:2);

    % Ensemble object.
    elseif isa(X, 'ensemble')
        Xtype = 1;
        ens = X;
       
        % Require scalar and static
        dash.assert.scalarType(ens, 'ensemble', 'ens', header);
        if ens.isevolving
            evolvingEnsembleError(ens, header);
        end

        % Get sizes. Check nMembers if there are estimates
        nState = ens.nRows;
        nMembers = ens.nMembers;
        if ~isnan(siz(2)) && nMembers~=obj.nMembers
            wrongMembersError(ens, nMembers, obj, header);
        end
    end

    % Check nState does not conflict with user metrics
    if obj.userMetric
        if obj.metricType==0 && nState~=1
            tooManyRowsError(obj, nState, header);
        elseif obj.metricType==1 && ~obj.metricDetails.defaultRows
            maxRow = max(obj.metricDetails.rows);
            if nState < maxRow
                notEnoughRowsError(obj, maxRow, nRows, header);
            end
        end

    % Or select default metrics
    else
        if nState == 1
            obj.metricType = 0;
        else
            obj.metricType = NaN;
        end
    end

    % Update object and return as output
    obj.nState = nState;
    obj.nMembers = nMembers;
    obj.X = X;
    obj.Xtype = Xtype;
    varargout = {obj};
end

end

%% Error messages
function[] = emptyPriorError(obj, header)
id = sprintf('%s:emptyPrior', header);
ME = MException(id, 'The prior for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
function[] = evolvingEnsembleError(ens, header)
id = sprintf('%s:evolvingEnsemble', header);
ME = MEXception(id, ['When using an ensemble object as a prior, the object ',...
    'must implement a static ensemble. However %s implements an evolving ',...
    'ensemble.'], ens.name);
throwAsCaller(ME);
end
function[] = wrongMembersError(ens, nMembers, obj, header)
id = sprintf('%s:wrongNumberMembers', header);
ME = MException(id, ['The number of ensemble members implemented by %s ',...
    '(%.f) does not match the number of ensemble members for %s (%.f).'],...
    ens.name, nMembers, obj.name, obj.nMembers);
throwAsCaller(ME);
end
function[] = tooManyRowsError(obj, nRows, header)
id = sprintf('%s:tooManyRows', header);
ME = MException(id, ['You previously specified that the prior should be used ',...
    'directly as the initial sensor metric. However, this option is only valid ',...
    'for priors with a single row, and the new prior for %s has %.f rows. Either ',...
    'reset the metric or use a different prior.'], obj.name, nRows);
throwAsCaller(ME);
end
function[] = notEnoughRowsError(obj, maxRow, nRows, header)
id = sprintf('%s:notEnoughRows', header);
ME = MException(id, ['You previously speciified a sensor metric that implements ',...
    'a mean using row %.f of the state vector. However, the new prior for %s ',...
    'only has %.f rows. Either reset the metric or use a different prior.'],...
    maxRow, obj.name, nRows, header);
throwAsCaller(ME);
end