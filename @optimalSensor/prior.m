function[varargout] = prior(obj, X)
%% optimalSensor.prior  Set or return the prior for an optimal sensor
% ----------
%   obj = obj.prior(X)
%   Provide the prior for an optimal sensor directly as a numeric array. 
%   Overwrites any previously specified prior. Each row is a state vector
%   element, and each column is an ensemble member.
%
%   obj = obj.prior(ens)
%   Provide the prior for an optimal sensor as an ensemble object.
%   Overwrites any previously specified prior. The ensemble object must be
%   a scalar object, and must implement a static prior.
%
%   X = obj.prior
%   ens = obj.prior
%   Returns the current prior for the particle filter object.
%
%   obj = obj.prior('delete')
%   Deletes the current prior from the particle filter object.
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

% Delete
elseif dash.is.string(X) && strcmpi(X, 'delete')
    obj.X = [];
    obj.nState = 0;
    if isempty(obj.Ye)
        obj.nMembers = 0;
    end
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

    % Set sizes
    obj.nState = nState;
    obj.nMembers = nMembers;

    % Save and build output
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