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
    obj.nState = 0;
    if isempty(obj.Ye)
        obj.nMembers = 0;
        obj.nPrior = 0;
    end

    % Collect output
    outputs = {obj};
    type = 'delete';

% Set estimates. Get defaults.
else
    if ~exist('whichPrior','var') || isempty(whichPrior)
        whichPrior = [];
    end


    %% Initial error checking

    % If estimates are set, require matching number of members and priors
    siz = NaN(1, 3);
    if ~isempty(obj.Ye)
        siz(2) = obj.nMembers;
        siz(3) = obj.nPrior;
    end

    % Numeric array. Require 3D of correct size with well-defined values.
    % Get sizes
    if isnumeric(X)
        dash.assert.blockTypeN(X, [], siz, 'X', header);
        dash.assert.defined(X, 2, 'X', header);
        [nState, nMembers, nPrior] = size(X, 1:3);

    % Ensemble object. Get sizes
    elseif isa(X, 'ensemble')
        ens = X;
        nState = ens.nRows;
        nMembers = ens.nMembers;
        nPrior = ens.nEvolving;

        % If scalar, optionally check nMembers and nPrior
        if isscalar(ens)
            if ~isnan(siz(2))
                if nMembers~=obj.nMembers
                    scalarEnsMembersError;
                elseif nPrior~=obj.nPrior
                    scalarEnsPriorError;
                end
            end

        % Otherwise, require a vector with an element per prior
        else
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


    %% Error check whichPrior

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

    % User did not provide whichPrior. If already set by prior, use
    % existing value. Otherwise if evolving, set time when unset. If set,
    % require one prior per time step
    if isempty(whichPrior)
        if whichIsSet
            whichPrior = obj.whichPrior;
        elseif obj.nPrior > 1
            if ~timeIsSet
                obj.nTime = obj.nPrior;
            end
            if obj.nPrior ~= obj.nTime
                wrongSizeError;
            end
            whichPrior = (1:obj.nTime)';
        end

    % Parse user-provided whichPrior. If already set by the prior, require
    % identical values
    elseif whichIsSet
        if isrow(whichPrior)
            whichPrior = whichPrior';
        end
        if ~isequal(obj.whichPrior, whichPrior)
            differentWhichError;
        end

    % Otherwise, user values can set whichPrior. If time is set, require
    % one element per time step. If unset and evolving, set nTime to the
    % number of priors
    else
        nRequired = [];
        if timeIsSet
            nRequired = obj.nTime;
        elseif obj.nPrior > 1
            obj.nTime = numel(whichPrior);
        end
        dash.assert.vectorTypeN(whichPrior, 'numeric', nRequired, 'whichPrior', header);
        linearMax = 'the number of priors';
        dash.assert.indices(whichPrior, obj.nPrior, 'whichPrior', [], linearMax, header);
    end


    %% Save and update

    % Save
    obj.X = X;
    if obj.nPrior > 1
        obj.whichPrior = whichPrior(:);
    end

    % Collect outputs
    outputs = {obj};
    type = 'set';
end

end