function[outputs, type] = prior(obj, header, X, whichPrior)

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:ensembleFilter:prior";
end

% Return estimates
if ~exist('X','var')
    outputs = {obj.X, obj.whichPrior};
    type = 'return';

% Delete current prior, don't allow second input
elseif dash.is.strflag(X) && strcmpi(X, 'delete')
    if exist('whichPrior','var')
        dash.error.tooManyInputs;
    end

    % Delete and reset sizes
    obj.X = [];
    obj.Xtype = NaN;

    obj.nState = 0;
    if isempty(obj.Ye)
        obj.nMembers = 0;
        obj.nPrior = 0;
        obj.whichPrior = [];
    end
    if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior)
        obj.nTime = 0;
    end

    % Collect output
    outputs = {obj};
    type = 'delete';

% Set estimates. Get defaults.
else
    if ~exist('whichPrior','var') || isempty(whichPrior)
        whichPrior = [];
    end

    % Don't allow empty array
    if isempty(X)
        emptyPriorError;
    end

    % If estimates are set, require matching number of members and priors
    siz = NaN(1, 3);
    if ~isempty(obj.Ye)
        siz(2) = obj.nMembers;
        siz(3) = obj.nPrior;
    end

    % Numeric array. Require 3D of correct size with well-defined values.
    % Get sizes
    if isnumeric(X)
        dash.assert.blockTypeSize(X, ["single";"double"], siz, 'X', header);
        dash.assert.defined(X, 2, 'X', header);
        [nState, nMembers, nPrior] = size(X, 1:3);
        Xtype = 0;

    % Ensemble object. Get sizes
    elseif isa(X, 'ensemble')
        ens = X;
        nState = ens.nRows;
        nMembers = ens.nMembers;
        nPrior = ens.nEvolving;

        % If scalar, optionally check nMembers and nPrior
        if isscalar(ens)
            Xtype = 1;
            if ~isnan(siz(2))
                if nMembers~=obj.nMembers
                    scalarEnsMembersError;
                elseif nPrior~=obj.nPrior
                    scalarEnsPriorError;
                end
            end

        % Otherwise, require a vector with an element per prior
        else
            Xtype = 2;
            dash.assert.vectorTypeN(ens, [], siz(3), 'ens', header);

            % Require static ensembles with the same number of state vector
            % elements and ensemble members
            if any(nPrior~=1)
                evolvingEnsembleError;
            elseif numel(unique(nState)) ~= 1
                differentStateError;
            elseif numel(unique(nMembers)) ~= 1
                differentMembersError;
            end

            % Get sizes for vector of objects
            nState = nState(1);
            nMembers = nMembers(1);
            nPrior = numel(ens);

            % Optionally check nMembers and nPrior
            if ~isnan(siz(2))
                if nMembers~=obj.nMembers
                    vectorEnsMembersError;
                elseif nPrior ~= obj.nPrior
                    vectorEnsPriorError;
                end
            end
        end
    end

    % Set sizes
    obj.nState = nState;
    obj.nMembers = nMembers;
    obj.nPrior = nPrior;

    % Note if whichPrior is already set by the estimates
    whichIsSet = false;
    if ~isempty(obj.Ye) && ~isempty(obj.whichPrior)
        whichIsSet = true;
    end

    % Note whether allowed to set nTime
    timeIsSet = true;
    if isempty(obj.Y) && isempty(obj.whichR) && ~whichIsSet
        timeIsSet = false;
    end

    % Error check and process whichPrior
    obj = obj.processWhich(whichPrior, 'whichPrior', obj.nPrior, 'priors',...
                                            timeIsSet, whichIsSet, header);

    % Save and build output
    obj.X = X;
    obj.Xtype = Xtype;
    outputs = {obj};
    type = 'set';
end

end